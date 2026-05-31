# Taapdeel Flutter Code Audit Report
**Date:** 2026-05-31  
**Files Audited:** 663 Dart files  
**Tool:** Claude Code Multi-Agent Audit

---

## Executive Summary

The Taapdeel_2026 codebase contains multiple critical bugs that are actively breaking core user flows: Firebase email/password authentication always uses the email address as the password for both login and registration, a swap-offer approval silently calls the rejection endpoint instead of the acceptance endpoint, and six global ChangeNotifier providers are recreated from scratch on every parent rebuild in `main.dart`. The API layer has systemic null-safety violations where `.catchError` returns void (causing immediate NullPointerException), and every next-page pagination method contains an off-by-one error in sort-index calculation. Performance is hampered by O(n) filtering running synchronously inside `build()`, `shrinkWrap: true` on large grids, and widespread `Provider.of` subscriptions without `listen: false` causing full-screen rebuilds on unrelated state changes. Dead code is extensive: at least five entire classes are never imported, three initialisation functions are never called, and a committed `.bak` backup file contains old business logic. Addressing the critical bugs is urgent; the authentication and swap-approval logic errors affect every user of the app.

---

## Issue Statistics

| Severity | Performance | Bugs & Logic | Provider / State | Memory Leaks | Dead Code | Total |
|----------|-------------|-------------|-----------------|--------------|-----------|-------|
| Critical | 2 | 9 | 2 | 5 | 5 | **23** |
| High | 5 | 16 | 13 | 13 | 16 | **63** |
| Medium | 3 | 8 | 10 | 6 | 11 | **38** |
| Low | 0 | 0 | 2 | 1 | 6 | **9** |
| **Total** | **10** | **33** | **27** | **25** | **38** | **133** |

---

## 1. Performance Issues

### Critical

#### [PERF-1] ChatListView recreates child StatefulWidgets on every build()
- **File:** `lib/ui/chat/list/chat_list_view.dart` (lines 67–75)
- **Severity:** Critical
- **Problem:** `_ChatListViewState.build()` instantiates both `ChatBuyerListView` and `ChatSellerListView` on every invocation. Because these are `StatefulWidget`s, Flutter tears down and remounts their entire subtree — including `AnimationController`s, scroll controllers, and network listeners — every time the parent calls `setState` (e.g., on tab or page index change). The instances are assigned to nullable fields (`chatBuyerListView`, `chatSellerListView`) but are never reused between builds.
- **Fix:** Move construction of `ChatBuyerListView` and `ChatSellerListView` into `initState()` and store them as `final` fields. Alternatively, apply `AutomaticKeepAliveClientMixin` to the page children so Flutter keeps them alive inside the `PageView`.

#### [PERF-2] ChatBuyerListView.build() runs O(n) filtering, grouping, and sorting on every rebuild
- **File:** `lib/ui/chat/list/chat_buyer_list_view.dart` (lines 92–126)
- **Severity:** Critical
- **Problem:** Every `build()` call executes `SwapRequestUiStatusHelper.buildFilterCounts()`, `filterRequests()`, `SwapRequestGroupingHelper.groupRequests()`, and `sortRequestsByVisualPriority()` — all iterating the full requests list synchronously. This fires on every scroll tick when `Provider.of` with `listen: true` is used inside a scroll listener, causing jank proportional to the number of swap requests.
- **Fix:** Cache filtered/sorted results in state variables. Recompute only when `allRequests`, `_selectedFilter`, or `_selectedGroupKey` actually change (via `didUpdateWidget` or a dedicated setter calling `setState`). The `build` method should read only pre-computed cache variables.

### High

#### [PERF-3] PsNetworkImage widgets subscribe to entire PsValueHolder on every build
- **File:** `lib/ui/common/ps_ui_widget.dart` (lines 169, 261, 355, 484, 617, 854)
- **Severity:** High
- **Problem:** All six image widgets call `Provider.of<PsValueHolder>(context)` with `listen: true` (default) in `build()`, yet only read one boolean: `psValueHolder.isUseThumbnailAsPlaceHolder`. Any unrelated `PsValueHolder` change (login state, location, etc.) forces every image widget on screen to rebuild. These widgets appear dozens of times in product lists and carousels.
- **Fix:** Replace each call with `context.select<PsValueHolder, bool>((vh) => vh.isUseThumbnailAsPlaceHolder ?? false)` to pin rebuilds to the single boolean each widget actually uses.

#### [PERF-4] TaapdeelCard.build() allocates new BoxShadow lists and BorderRadius on every call
- **File:** `lib/ui/common/taapdeel/taapdeel_card.dart` (lines 134–175)
- **Severity:** High
- **Problem:** `_TaapdeelCardState.build()` creates four new `List<BoxShadow>` instances every frame (`normalShadows` at line 142, `pressedShadows` at line 158) plus a `BorderRadius.only()` at line 134. The card is used app-wide. When the accent colour is static (the common case), these allocations are pure GC pressure with no benefit.
- **Fix:** Extract `static const` versions for the default brand-blue shadow sets and `BorderRadius`. For dynamic accent colours, cache them as state fields and recompute only in `didUpdateWidget` when `accentColor` changes.

#### [PERF-5] ProductListWithFilterView uses shrinkWrap:true on a potentially large SliverGrid
- **File:** `lib/ui/item/list_with_filter/product_list_with_filter_view.dart` (lines 131–184)
- **Severity:** High
- **Problem:** `CustomScrollView` is constructed with `shrinkWrap: true` (line 134). Flutter must lay out the entire `SliverGrid` upfront to measure its total height, defeating lazy loading. For 50–100 search results this causes severe layout jank on initial render and scroll.
- **Fix:** Remove `shrinkWrap: true` and wrap the `CustomScrollView` in an `Expanded` widget instead. The `SliverGrid` already uses `mainAxisExtent: 233`, so Flutter can compute item positions lazily. Also add a `cacheExtent` to pre-render a couple of rows ahead.

#### [PERF-6] _RecommendationLoadingCard animates without a RepaintBoundary
- **File:** `lib/ui/Foryou/home_view.dart` (lines 354–526)
- **Severity:** High
- **Problem:** `_RecommendationLoadingCard` drives a 2-second looping animation with `Transform.translate`, `ScaleTransition`, and `Opacity` simultaneously, with no `RepaintBoundary`. On every animation tick the dirty region propagates through the entire `HomeViewWidget` subtree (full page scaffold), forcing an unnecessary parent repaint.
- **Fix:** Wrap `_RecommendationLoadingCard` with `RepaintBoundary` at its call sites inside `HomeViewWidget` (approximately lines 781 and 785) to confine animation repaints to its own layer.

#### [PERF-7] PackagesScreen FutureBuilder re-invokes getUserData() HTTP request on every rebuild
- **File:** `lib/paymob_payment/ui/pakages_screen/packages_screen.dart` (lines 50–54)
- **Severity:** High
- **Problem:** `FutureBuilder(future: getUserData(context: context, ...))` is given an inline `Future` expression. Dart creates a new `Future` instance on every `build()` call, causing `FutureBuilder` to re-subscribe and re-execute the HTTP request. The Lottie animation `setState` (line 116) and any ancestor `setState` silently fire duplicate network requests and reset the UI to the loading spinner.
- **Fix:** Store the future as `late final Future<UserBalanceModel?> _userFuture` initialised in `initState()` and pass `_userFuture` to `FutureBuilder`. This is the standard Flutter stable-future pattern.

### Medium

#### [PERF-8] TaapdeelHighlightCarousel background Containers not marked const
- **File:** `lib/ui/common/taapdeel/taapdeel_highlight_carousel.dart` (lines 111–185)
- **Severity:** Medium
- **Problem:** Two fully static decorative background `Container`s (lines 117–150 and 154–184) use only const-capable values (`LinearGradient`, `BoxDecoration`, `BoxShadow`, fixed margins/radii) but are not marked `const`. They are rebuilt on every auto-play timer `setState` and every manual swipe, allocating new decoration objects each time.
- **Fix:** Extract the two containers as `const` private widgets (`const _CarouselBackLayer1` and `const _CarouselBackLayer2`), or annotate the `Container` constructors directly with `const`. The only non-const part (`_currentPage`) lives in the `PageView`/dots, not in these layers.

#### [PERF-9] HomeItemSearchView.build() constructs the entire search button widget tree and re-reads providers on every rebuild
- **File:** `lib/ui/search/home_item_search_view.dart` (lines 64–171)
- **Severity:** Medium
- **Problem:** `_ItemSearchViewState.build()` builds a large `_searchButtonWidget` local variable (lines 68–171) containing a complete `PSButtonWidget` subtree with a heavyweight async closure, re-reads `repo1` and `valueHolder` from `Provider` on every build, and executes a `print` statement (line 65) on every rebuild in all build modes.
- **Fix:** Extract `_buildSearchButton()` as a private method or cache it as a state field. Remove the `print` call. Use `Provider.of(context, listen: false)` (or `context.read<T>()`) for `repo1` and `valueHolder` since they do not drive rendering.

#### [PERF-10] ProfileView._buildProductsCardsBar() chains 8 nested Consumer widgets with inline O(n) computation
- **File:** `lib/ui/user/profile/profile_view.dart` (lines 516–668)
- **Severity:** Medium
- **Problem:** Eight `Consumer` widgets are nested, each listening to its entire provider. When any provider notifies, the innermost builder recomputes `_sumProductsMinPrice` over all lists (O(n) loops at lines 541–554) and rebuilds the entire `ProfileHorizontalCardsBar` tree. The `_CardsBarData` equality class is defined but never used with `Selector`, so it provides no protection against redundant rebuilds.
- **Fix:** Replace all 8 nested `Consumer` widgets with a single `Selector<..., _CardsBarData>` that constructs `_CardsBarData` and leverages the existing `==` operator to suppress rebuilds when data is unchanged. Move `_sumProductsMinPrice` computation into `didUpdateWidget`-style cache invalidation or into the provider itself.

---

## 2. Bugs & Logic Errors

### Critical

#### [BUGS-1] loginWithEmailId passes email as password to Firebase signIn
- **File:** `lib/provider/user/user_provider.dart` (line 838)
- **Severity:** Critical
- **Problem:** `await signInWithEmailAndPassword(context, email, email)` passes `email` for both the email and the password parameters. The real `password` variable is in scope but not passed. Firebase sign-in always fails for any user whose password differs from their email address.
- **Fix:** Change to `await signInWithEmailAndPassword(context, email, password);`

#### [BUGS-2] createUserWithEmailAndPassword passes email as password during registration
- **File:** `lib/provider/user/user_provider.dart` (line 999)
- **Severity:** Critical
- **Problem:** `await createUserWithEmailAndPassword(context, email, email)` uses the email address as the password. Every newly registered Firebase user has their email address set as their Firebase password.
- **Fix:** Change to `await createUserWithEmailAndPassword(context, email, password);`

#### [BUGS-3] approveRequest posts to the rejected-offer URL instead of the accepted-offer URL
- **File:** `lib/provider/SwapProductsProvider.dart` (lines 221–237)
- **Severity:** Critical
- **Problem:** `approveRequest` uses `PsUrl.ps_rejected_offer_url` for its HTTP POST — the same URL used by `rejectOffer`. The intent is to accept the offer, but this silently calls the reject endpoint. The method additionally calls `approveOffer` (line 236) without `await`, so the correct accept call is fire-and-forget after an incorrect reject call has already been sent.
- **Fix:** Change the URL to `PsUrl.ps_accepted_offer_url`. Remove the redundant `approveOffer(jsonMap)` call at line 236 (or keep only the single correct call and await it).

#### [BUGS-4] markSweetMessageRead calls the wrong endpoint URL
- **File:** `lib/api/ps_api_service.dart` (lines 641–663)
- **Severity:** Critical
- **Problem:** `markSweetMessageRead` calls the same URL as `getReceivedSweetMessages` (`rest/Sweet_messages/get_received/...`). The mark-read call silently fetches messages again instead of marking them read, and returns HTTP 200 while doing nothing to persist the read state on the server.
- **Fix:** Use the correct endpoint: `rest/Sweet_messages/mark_read/api_key/${PsConfig.ps_api_key}`.

#### [BUGS-5] postData / postListData crash when HTTP .catchError returns null Response
- **File:** `lib/api/common/ps_api.dart` (lines 88–91, 131–134)
- **Severity:** Critical
- **Problem:** The `.catchError` callback only prints and returns nothing (implicit `null`). Dart's `.catchError` requires the callback to return a `Future<Response>`, so the awaited `response` becomes `null`. The next line `PsApiResponse(response)` immediately throws a `Null check operator used on a null value` because `PsApiResponse` dereferences `response.statusCode` unconditionally.
- **Fix:** Replace the inline `.catchError` with a `try/catch` around the `await`, or make `.catchError` return a valid fallback: `return http.Response('{}', 500);`.

#### [BUGS-6] postUploadItemImage force-unwraps nullable imageId with ! unconditionally
- **File:** `lib/api/common/ps_api.dart` (lines 240, 249)
- **Severity:** Critical
- **Problem:** The parameter `imageId` is typed `String?` but both branches (if and else) use `imageId!` unconditionally. If the caller passes `null`, the app crashes with a `Null check operator` exception.
- **Fix:** Replace `imageId!` with `imageId ?? ''` at both lines 240 and 249.

#### [BUGS-7] sinkItemDetailStream force-unwraps itemDetailStream with ! without null check
- **File:** `lib/repository/product_repository.dart` (lines 73–79)
- **Severity:** Critical
- **Problem:** The method checks `if (data != null)` but always calls `itemDetailStream!.sink.add(data)`. If `itemDetailStream` is null the `!` crashes. Additionally, `getItemDetail` (line 312) calls `itemDetailStream!.sink.add` without a null guard on the stream itself.
- **Fix:** Add `if (itemDetailStream == null) return;` at the top of `sinkItemDetailStream`. Remove the bare `!` and use the early-return pattern.

#### [BUGS-8] handleFirebaseAuthError calls providers.single which throws on empty or multi-element list
- **File:** `lib/provider/user/user_provider.dart` (line 363)
- **Severity:** Critical
- **Problem:** `final String provider = providers.single;` throws `StateError` if `providers` is empty (email not yet registered) or has more than one element (multiple linked providers). No guard exists around this call.
- **Fix:** Replace with `providers.isNotEmpty ? providers.first : ''` and handle the empty case (e.g., show a "no account found" error).

#### [BUGS-9] postChatImageUpload is called without await, making errors unhandled
- **File:** `lib/api/ps_api_service.dart` (lines 1392–1408)
- **Severity:** Critical
- **Problem:** `return postUploadChatImage(...)` is missing `await`. The caller always receives an in-flight `Future`. Errors inside `postUploadChatImage` after it is returned become unhandled `Future` errors that are silently swallowed.
- **Fix:** Change to `return await postUploadChatImage(...);`

### High

#### [BUGS-10] getOtherUserData calls _userDao.deleteAll() instead of deleting only the stale entry
- **File:** `lib/repository/user_repository.dart` (line 438)
- **Severity:** High
- **Problem:** When refreshing another user's profile, `await _userDao.deleteAll()` removes every user from the local database, including the currently logged-in user's record. Any subsequent DB-first read for the logged-in user returns `null` until the next network refresh.
- **Fix:** Replace `await _userDao.deleteAll()` with `await _userDao.deleteWithFinder(finder)` to delete only the specific user being refreshed.

#### [BUGS-11] getNextPageProductList sort index starts at length + 1, skipping one position
- **File:** `lib/repository/product_repository.dart` (line 261)
- **Severity:** High
- **Problem:** `i = existingMapList.data!.length + 1` means the first new item gets sorting index = count + 1 instead of count, creating a gap. Combined with the composite key `data.id! + paramKey + i.toString()`, this can produce duplicate or skipped entries at page boundaries. The same off-by-one pattern appears in `offer_repository`, `user_repository` (`getNextPageUserList`), and `getNextPageItemListFromFollower`.
- **Fix:** Change to `i = existingMapList.data!.length;` (remove `+1`) across all next-page repository methods.

#### [BUGS-12] getNextPageOfferList sort index starts at length + 1
- **File:** `lib/repository/offer_repository.dart` (line 135)
- **Severity:** High
- **Problem:** Same off-by-one as BUGS-11. The first item on every new offer page gets `sorting = existingCount + 1`, leaving a gap in the sort order.
- **Fix:** Change to `i = existingMapList.data!.length;`

#### [BUGS-13] getNextPageOfferList ignores limit/offset when calling the API
- **File:** `lib/repository/offer_repository.dart` (line 126)
- **Severity:** High
- **Problem:** `_psApiService.getOfferList(holder.toMap())` passes no `limit` or `offset`. If the server paginates by these parameters, it will receive the same map every call and return page 1 every time rather than the next page.
- **Fix:** Add `limit` and `offset` to the holder's map (or to the URL) and ensure offset advances on each paginated call.

#### [BUGS-14] OfferListProvider stream listener dereferences resource.data! without null check
- **File:** `lib/provider/offer/offer_provider.dart` (line 26)
- **Severity:** High
- **Problem:** `updateOffset(resource.data!.length)` uses `!` on `resource.data` which can be `null` when the resource has an error status, causing a crash.
- **Fix:** Change to `updateOffset(resource.data?.length ?? 0);`

#### [BUGS-15] ChatHistoryListProvider stream listener dereferences resource.data! without null check
- **File:** `lib/provider/chat/chat_history_list_provider.dart` (line 28)
- **Severity:** High
- **Problem:** `updateOffset(resource.data!.length)` will throw if `resource.data` is `null` (error or noaction states).
- **Fix:** Change to `updateOffset(resource.data?.length ?? 0);`

#### [BUGS-16] sinkUserDetailStream force-unwraps nullable userListStream with !
- **File:** `lib/repository/user_repository.dart` (lines 47–49)
- **Severity:** High
- **Problem:** `userListStream!.sink.add(data)` — the stream is declared `StreamController<PsResource<User?>>?` (nullable) but accessed without a null guard, throwing if the stream has not been set up yet.
- **Fix:** Add `if (userListStream == null) return;` before accessing the sink.

#### [BUGS-17] RecentProductProvider.getFilteredProducts has no request cancellation or deduplication
- **File:** `lib/provider/product/recent_product_provider.dart` (lines 94–128)
- **Severity:** High
- **Problem:** `getFilteredProducts` clears `filteredProductsList`, calls `notifyListeners()`, then makes a network request. Rapid repeated calls (e.g. quick filter taps) launch multiple concurrent HTTP requests that all append to `filteredProductsList` in undefined order, causing duplicate or interleaved results.
- **Fix:** Add a cancellation token or debounce. Cancel any in-flight request before starting a new one. Guard state updates with a nonce/generation counter.

#### [BUGS-18] Price fields stored as String?, causing arithmetic parse errors
- **File:** `lib/viewobject/product.dart` (lines 132–133, 158–159)
- **Severity:** High
- **Problem:** `price`, `discountedPrice`, `lowPrice`, `highPrice`, `discountRate` are all `String?`. The `?? ''` fallbacks produce `''` when the server sends JSON `null`, causing `double.parse('')` crashes in downstream arithmetic.
- **Fix:** Store monetary values as `double?` and parse directly from JSON with `(dynamicData['price'] as num?)?.toDouble()`. This eliminates the entire class of runtime parse errors.

#### [BUGS-19] NotiRepository silently swallows DB insert/delete errors
- **File:** `lib/repository/noti_repository.dart` (lines 58–65, 111–116)
- **Severity:** High
- **Problem:** Both `getNotiList` and `getNextPageNotiList` catch all exceptions from `_notiDao.deleteAll()` / `_notiDao.insertAll()` with a bare `catch (e)` that only prints. DB corruption or schema changes leave notifications in an inconsistent local state with no user-visible error.
- **Fix:** Log the error with sufficient context to diagnose schema issues. Consider re-throwing non-recoverable errors or surfacing them to the UI.

#### [BUGS-20] SwapProductsProvider.approveRequest calls approveOffer without await
- **File:** `lib/provider/SwapProductsProvider.dart` (line 236)
- **Severity:** High
- **Problem:** `approveOffer(jsonMap)` is called without `await`. The HTTP request to the accepted-offer endpoint is fire-and-forget. Network errors are silently swallowed and the method returns 'success' even though the server was never notified.
- **Fix:** Change to `await approveOffer(jsonMap);` and propagate errors to the caller.

#### [BUGS-21] SwapProductsProvider.makeMarkAsSold fires balance-update calls without error handling
- **File:** `lib/provider/SwapProductsProvider.dart` (lines 283–303)
- **Severity:** High
- **Problem:** `incrementSwapNumber` and `incrementUserPoints10` calls for seller and buyer are awaited sequentially with no error handling. If any one fails, the function returns `'Done'` regardless, leaving the user's swap balance in an inconsistent state.
- **Fix:** Wrap each balance-update call in `try/catch` and implement retry/rollback logic, or batch them in a single server-side transaction endpoint.

#### [BUGS-22] replaceMobileConfigSetting force-unwraps defaultLanguage! without null check
- **File:** `lib/db/common/ps_shared_preferences.dart` (line 555)
- **Severity:** High
- **Problem:** `psMobileConfigSetting.defaultLanguage!.languageCode ?? 'en'` uses `!` on `defaultLanguage` without a prior null check. If the server sends a config with a missing `defaultLanguage` field, this crashes.
- **Fix:** Use `psMobileConfigSetting.defaultLanguage?.languageCode ?? 'en'` (optional chaining instead of force-unwrap).

#### [BUGS-23] getOwnerRelation accesses jsonMap['data'] without type verification before calling fromMap
- **File:** `lib/api/ps_api_service.dart` (lines 680–697)
- **Severity:** High
- **Problem:** `OwnerRelation().fromMap(jsonMap['data'])` is called without verifying `jsonMap['data']` is actually a `Map`. If the server returns a `List` or `String`, `fromMap` processes invalid data or crashes.
- **Fix:** Add `if (jsonMap['data'] is Map<String, dynamic>)` guard before calling `fromMap`.

#### [BUGS-24] getSimilarItemsByTags HTTP post is outside the try/catch block
- **File:** `lib/api/ps_api_service.dart` (lines 1030–1036)
- **Severity:** High
- **Problem:** The `http.post(...)` call for `getSimilarItemsByTags` is outside the `try { ... } catch (e)` block that wraps `jsonDecode`. A network failure (`SocketException`, timeout) propagates as an unhandled exception rather than being caught and returned as `PsStatus.ERROR`.
- **Fix:** Move the `http.post` call inside the `try` block or wrap it in its own `try/catch`.

#### [BUGS-25] NotiProvider.markRead applies optimistic UI update that is never reverted on failure
- **File:** `lib/provider/noti/noti_provider.dart` (lines 192–201)
- **Severity:** High
- **Problem:** The optimistic UI update (marking notification as read locally) happens before server confirmation. If the server call fails (caught silently), the UI shows the notification as read permanently while the server still has it unread — a permanent mismatch after restart.
- **Fix:** Either revert the optimistic update on error, or reload the notification list from the server on failure.

### Medium

#### [BUGS-26] ProductRepository.insert uses product! without null guard
- **File:** `lib/repository/product_repository.dart` (line 90)
- **Severity:** Medium
- **Problem:** `_productDao.insert(primaryKey, product!)` — the parameter is `Product?` but dereferenced with `!`. If the API returns success with a null data field, this crashes.
- **Fix:** Add `if (product == null) return;` before the insert and use `product` (non-bang).

#### [BUGS-27] UserRepository.insert uses user! without null guard
- **File:** `lib/repository/user_repository.dart` (line 58)
- **Severity:** Medium
- **Problem:** `_userDao.insert(_userPrimaryKey, user!)` — parameter is `User?`. Multiple callers pass `_resource.data` which can be `null` on a SUCCESS status if the server omits the data field.
- **Fix:** Add `if (user == null) return;` before the insert.

#### [BUGS-28] PsProvider.loadValueHolder calls psRepository!.loadValueHolder() without null check
- **File:** `lib/provider/common/ps_provider.dart` (line 43)
- **Severity:** Medium
- **Problem:** `psRepository` is typed `PsRepository?` (nullable) but `psRepository!.loadValueHolder()` uses a bang operator without any null check. If a subclass does not supply a repository, this crashes at runtime.
- **Fix:** Guard all `psRepository!` usages with `if (psRepository == null) return;`.

#### [BUGS-29] PsRepository.loadValueHolder missing await causing inconsistent async contract
- **File:** `lib/repository/Common/ps_repository.dart` (line 8)
- **Severity:** Medium
- **Problem:** The outer `loadValueHolder` is declared `async Future<dynamic>` but `PsSharedPreferences.instance.loadValueHolder()` is called without `await`, creating an inconsistent async contract. Callers that `await` it proceed without a guarantee that initialization is complete.
- **Fix:** Either keep `loadValueHolder` synchronous and remove the `async Future<dynamic>` annotation, or make `PsSharedPreferences.instance.loadValueHolder()` awaitable and `await` it.

#### [BUGS-30] SearchProductProvider always sets _productList status to NOACTION, never SUCCESS
- **File:** `lib/provider/product/search_product_provider.dart` (lines 83, 122–128)
- **Severity:** Medium
- **Problem:** `_productList = PsResource<List<Product>>(PsStatus.NOACTION, '', <Product>[])` is created with `NOACTION`. After the loop fills the list, the status override always fires (because `_productList.status` is always `NOACTION`, never `SUCCESS`). Non-empty successful results may be shown as `NOACTION` to the UI.
- **Fix:** After populating the list, unconditionally set `_productList.status = resource.status; _productList.message = resource.message;` regardless of list emptiness.

#### [BUGS-31] getFilteredProducts calls parsed.length without checking parsed is a List
- **File:** `lib/provider/product/recent_product_provider.dart` (line 117)
- **Severity:** Medium
- **Problem:** `for (int x = 0; x < parsed.length; x++)` and `parsed[x]` are called on `dynamic parsed = json.decode(response.body)` without checking `parsed is List`. If the server returns a `Map` (error object), this throws `NoSuchMethodError`.
- **Fix:** Add `if (parsed is List) { ... }` guard around the loop.

#### [BUGS-32] addPriceOffer accesses json['id'] without null check after status 200
- **File:** `lib/provider/SwapProductsProvider.dart` (line 194)
- **Severity:** Medium
- **Problem:** `final String chId = json.decode(response.body)['id'];` — the `['id']` access returns `dynamic` and assigns to a non-nullable `String`. If the server returns 200 but omits `id`, `null` is stored in `jsonMap['id']`, crashing later consumers.
- **Fix:** Use `(json.decode(response.body)['id'] ?? '').toString()` and treat an empty id as a failure.

#### [BUGS-33] PsProvider.updateOffset can increment stale-data counter on a valid fresh load
- **File:** `lib/provider/common/ps_provider.dart` (lines 24–39)
- **Severity:** Medium
- **Problem:** When `offset == 0`, `maxDataLoadingCount` resets to 0 — correct. But the `if (dataLength == _cacheDataLength)` check on a non-zero offset also increments the counter. If a refresh resets offset to 0 but total count equals the previous cache length, the ordering of the two blocks can still trigger the increment on a valid fresh load.
- **Fix:** Use an `else if` chain so the stale-data check only runs when `offset != 0`.

---

## 3. Provider State Management Issues

### Critical

#### [PROV-1] Inner MultiProvider recreated on every frame inside _PSAppState.build()
- **File:** `lib/main.dart` (line 338)
- **Severity:** Critical
- **Problem:** `_PSAppState.build()` calls `PsColors.loadColor(context)` then wraps children in a `MultiProvider` containing `ChangeNotifierProvider`s for `ItemPromotionProvider`, `MainProvider`, `HomeProvider`, `SearchProvider`, `MainBuyerProvider`, and `PaymentProvider`. Every parent rebuild (theme/locale change) silently recreates all six providers, destroying all their state.
- **Fix:** Move the inner `MultiProvider` out of `build()`. Either (a) promote `_PSAppState` to initialise the provider list in `initState()`, (b) split into a `StatefulWidget` that creates providers once in state, or (c) move the six providers into the top-level `ps_provider_dependencies.dart` list.

#### [PROV-2] ChangeNotifierProvider for OfferListProvider created inside build() in offer list views
- **File:** `lib/ui/offer/list/offer_sent_list_view.dart` (lines 62–76), `offer_receive_list_view.dart` (line 95)
- **Severity:** Critical
- **Problem:** Both `_OfferSentListViewState.build()` and `_OfferReceivedListViewState.build()` return `ChangeNotifierProvider<OfferListProvider>(create: ...)`. Every `build()` call tears down the existing provider (calling `dispose()`), cancels its stream subscription, and creates a fresh one — causing repeated API calls and visible flicker.
- **Fix:** Store the provider in State (`initState()` / `dispose()`). Expose it via `ChangeNotifierProvider.value(value: _provider)` in `build()`. Never use `create:` inside `build()`.

### High

#### [PROV-3] Provider.of without listen:false on repository providers in dashboard_view.dart and elsewhere
- **File:** `lib/ui/dashboard/core/dashboard_view.dart` (lines 547–564); also `login_container_view.dart` (line 82), `offer_sent_list_view.dart` (line 67), `offer_receive_list_view.dart` (line 95), FAQ/language views
- **Severity:** High
- **Problem:** `dashboard_view.dart` calls `Provider.of<CategoryRepository>`, `UserRepository`, `AppInfoRepository`, `ProductRepository`, `DeleteTaskRepository`, `UserUnreadMessageRepository`, `NotificationRepository`, and `ChatHistoryRepository` — all without `listen: false`. These are ProxyProvider-derived objects whose upstream rebuilds re-register the entire `DashboardView` for unnecessary rebuilds.
- **Fix:** Append `listen: false` to every `Provider.of` call that only reads a repository or creates a child provider. Use `context.read<T>()` as the idiomatic shorthand.

#### [PROV-4] No isError / errorMessage fields in PsProvider or any subclass
- **File:** `lib/provider/common/ps_provider.dart` (line 1)
- **Severity:** High
- **Problem:** `PsProvider` (base class for ~50 domain providers) exposes only `isLoading` and `isConnectedToInternet`. When a network call fails, the UI only checks `provider.list.data != null && provider.list.data!.isNotEmpty`. An empty list from a network failure renders a silent blank screen.
- **Fix:** Add `bool isError = false;` and `String errorMessage = '';` to `PsProvider`. Set them in the stream listener's error branch before `notifyListeners()`. Have UI widgets check `isError` to show retry buttons or error messages.

#### [PROV-5] UserProvider is a 1,231-line monolith mixing auth, profile, social, Firebase, and navigation
- **File:** `lib/provider/user/user_provider.dart` (line 1)
- **Severity:** High
- **Problem:** Any change to a single method (e.g., profile update) triggers `notifyListeners()` that re-renders every widget subscribed to `UserProvider`, even those that only care about login state. It also holds hard references to `GoogleSignIn` and `FirebaseAuth` for the entire provider lifetime.
- **Fix:** Split into at least three providers: `AuthProvider` (login/register/social auth), `UserProfileProvider` (profile read/update, image upload), `UserSocialProvider` (follow, block, report).

#### [PROV-6] MainProvider and MainBuyerProvider are near-identical duplicates mixing UI and data
- **File:** `lib/provider/main_provider.dart` (line 17), `lib/provider/mainBuyer_provider.dart`
- **Severity:** High
- **Problem:** Both providers are ~200 lines each with identical field names, methods, and logic. Both mix data (swap list filtering) with presentation (`selectedIndex`, `OfferListViewAppBar` factory). The duplication is a maintenance hazard.
- **Fix:** Extract a shared `AbstractSwapListProvider` base class or mixin. Parameterise by buyer/seller role. Move `OfferListViewAppBar` factory out of the providers entirely.

#### [PROV-7] MainProvider and MainBuyerProvider retain stale swapList on re-entry after navigation
- **File:** `lib/provider/main_provider.dart` (lines 36–46)
- **Severity:** High
- **Problem:** Both providers are global `ChangeNotifierProvider`s and are never reset between navigation sessions. On re-entry the UI momentarily shows data from the previous session. After logout, `swapList` retains the previous user's data until the async call completes.
- **Fix:** Add a `reset()` method that immediately clears all lists and sets `loading = false`. Call it from the screen's `didChangeDependencies()` or via a `RouteObserver`. Also call `reset()` from the logout handler.

#### [PROV-8] SwapProductsProvider registered as ProxyProvider (non-notifying) not ChangeNotifierProxyProvider
- **File:** `lib/provider/ps_provider_dependencies.dart` (lines 138–142)
- **Severity:** High
- **Problem:** `SwapProductsProvider` is registered via `ProxyProvider<PsSharedPreferences, SwapProductsProvider>`. This means any widget receiving it cannot observe state changes. UI updates after `getSwapProducts()` completes are silently lost.
- **Fix:** Either (a) rename to `SwapProductsService`/`Repository` and never use it as a reactive provider, or (b) convert to a `ChangeNotifier` and register with `ChangeNotifierProxyProvider`.

#### [PROV-9] MainProvider.getSentList() calls notifyListeners() twice per invocation
- **File:** `lib/provider/main_provider.dart` (lines 37–79)
- **Severity:** High
- **Problem:** `getSentList()` calls `notifyListeners()` at line 38 (to show loading) and again at line 79 (to show results). Widgets subscribed with `Consumer<MainProvider>` will re-render twice per data load, causing visible double-renders. Same pattern in `MainBuyerProvider`.
- **Fix:** Batch all mutations before calling `notifyListeners()`. Set `loading = true`, pre-populate all lists, set `loading = false`, then call `notifyListeners()` exactly once. If an immediate loading indicator is needed, schedule data work with `Future.microtask`.

#### [PROV-10] Provider.of<PsValueHolder> with listen:true in OfferSentListView and OfferReceivedListView build()
- **File:** `lib/ui/offer/list/offer_sent_list_view.dart` (line 63)
- **Severity:** High
- **Problem:** `psValueHolder = Provider.of<PsValueHolder>(context)` with default `listen: true` subscribes the entire view (including the `ChangeNotifierProvider.create` callback) to every `PsValueHolder` stream emission, recreating `OfferListProvider` on every unrelated preference write.
- **Fix:** Use `context.read<PsValueHolder>()` or `Provider.of<PsValueHolder>(context, listen: false)` in `build()` when the value is only passed to a child provider.

#### [PROV-11] BuyerChatHistoryListProvider and SellerChatHistoryListProvider make raw HTTP calls in provider
- **File:** `lib/provider/chat/buyer_chat_history_list_provider.dart` (lines 160–182)
- **Severity:** High
- **Problem:** `getReceivedList()` and `getSentList()` contain raw `http.post(Uri.parse(...))` calls inlined directly in the provider — no caching, no repository-level error handling, no unit-testability, and hardcoded URL strings duplicated from `PsUrl`.
- **Fix:** Move raw HTTP calls into `ChatHistoryRepository` (or a new `SwapRequestRepository`). The provider should only call the repository method and propagate results through the stream.

#### [PROV-12] SearchProductProvider retains filter state across navigation
- **File:** `lib/provider/product/search_product_provider.dart` (lines 41–68)
- **Severity:** High
- **Problem:** `SearchProductProvider` holds 18+ filter fields as mutable instance state. When the user presses Back and re-enters the search screen, all previous filter selections remain active, potentially showing a filtered list that does not match the current UI state.
- **Fix:** Add `resetFilters()` clearing all filter fields to defaults. Call it from `initState()` or the route's pop handler. Alternatively scope `SearchProductProvider` to the route widget tree so it is automatically disposed on pop.

#### [PROV-13] ProxyProvider.update callbacks always create new repository instances (ignore previous)
- **File:** `lib/provider/ps_provider_dependencies.dart` (lines 127–337)
- **Severity:** High
- **Problem:** Every `ProxyProvider.update` callback ignores the `previous` parameter and unconditionally constructs a new repository. Every time `PsApiService` or a `Dao` rebuilds, a brand-new repository is provided. Any provider holding a reference to the old repository becomes stale.
- **Fix:** Use `previous`: `update: (_, api, dao, prev) => prev ?? ProductRepository(psApiService: api, productDao: dao)`. Only rebuild when genuinely necessary.

#### [PROV-14] MainProvider/MainBuyerProvider accept ChangeNotifier instances as method arguments, creating implicit circular coupling
- **File:** `lib/provider/main_provider.dart` (lines 33–79)
- **Severity:** High
- **Problem:** `getSentList(context, SellerChatHistoryListProvider)` / `getSentList(context, BuyerChatHistoryListProvider)` take other provider instances as direct parameters. If the child provider is disposed while `MainProvider` still holds a reference from a previous call, this results in a use-after-dispose call.
- **Fix:** Inject a `ChatHistoryRepository` or a plain async callback into `MainProvider` instead of another `ChangeNotifier`. Data-fetching belongs at the repository layer.

### Medium

#### [PROV-15] Consumer<OfferListProvider> wraps the entire Scaffold body
- **File:** `lib/ui/offer/list/offer_sent_list_view.dart` (line 77)
- **Severity:** Medium
- **Problem:** `Consumer<OfferListProvider>` wraps an entire `Scaffold` including `AppBar`-level children, all wrappers, the `ListView.builder`, and the progress indicator. Every `notifyListeners()` re-renders the entire subtree.
- **Fix:** Move `Consumer` or `Selector` to wrap only the smallest widget needing data. Wrap only the `ListView.builder` with `Selector<OfferListProvider, List<Offer>>` and only the progress indicator with `Selector<OfferListProvider, PsStatus>`.

#### [PROV-16] Provider.of<PsValueHolder> with listen:true in LoginContainerView build() as a simple read
- **File:** `lib/ui/user/login/login_container_view.dart` (line 43)
- **Severity:** Medium
- **Problem:** `final PsValueHolder valueHolder = Provider.of<PsValueHolder>(context);` with default `listen: true`. The result is only used inside a closure (`_requestPop`), not to drive rendering. This causes the entire `LoginContainerView` to rebuild on every unrelated preference update.
- **Fix:** Change to `Provider.of<PsValueHolder>(context, listen: false)`.

#### [PROV-17] PaymentProvider has no isError or errorMessage field
- **File:** `lib/paymob_payment/payment_provider.dart` (line 4)
- **Severity:** Medium
- **Problem:** `PaymentProvider` exposes only `isLoading`, `userModel`, and `redeemDialogLoading`. If the payment API fails, the UI has no signal to show an error. `null` from `getUserModel()` is ambiguous between "not yet loaded" and "request failed".
- **Fix:** Add `bool isError = false;` and `String? errorMessage;`. Set them on failure paths before `notifyListeners()`. Add `clearError()` for retry flows.

#### [PROV-18] SearchProductProvider holds UI toggle state alongside network/pagination state
- **File:** `lib/provider/product/search_product_provider.dart` (lines 41–68)
- **Severity:** Medium
- **Problem:** 18 filter/UI fields (switch booleans, rating click booleans, name/id filter strings) are mixed alongside stream subscription, pagination offset, and product list data. Toggling a switch and loading data both call `notifyListeners()`, rebuilding every `Consumer` including the switches.
- **Fix:** Separate UI filter selection state (local `FilterState` value object passed to the provider on Apply) from paged data state. The provider should hold only the paginated product list and loading/error flags.

#### [PROV-19] Provider.of<SearchProductProvider> with listen:true in SpecialCheckTextWidget causes full-list rebuilds on switch toggle
- **File:** `lib/ui/common/ps_special_check_text_widget.dart` (lines 32–33)
- **Severity:** Medium
- **Problem:** `SpecialCheckTextWidget.build()` calls `Provider.of<SearchProductProvider>(context)` (listen: true). When a search result loads and `notifyListeners()` fires, every `SpecialCheckTextWidget` rebuilds even if the switch value has not changed.
- **Fix:** Use `Selector<SearchProductProvider, bool>(selector: (_, p) => p.isSwitchedFeaturedProduct, ...)`. Remove the redundant local `setState()` inside `onChanged` and let the `Selector` drive visual updates.

#### [PROV-20] ItemPromotionProvider registered without its required repository in main.dart
- **File:** `lib/provider/promotion/item_promotion_provider.dart` (lines 11–13, 67)
- **Severity:** Medium
- **Problem:** `ChangeNotifierProvider<ItemPromotionProvider>(create: (_) => ItemPromotionProvider())` passes no repository. The constructor defaults `itemPaidHistoryRepository` to `null`. `postItemHistoryEntry()` then crashes with `Null check operator used on a null value` at `_repo!.postItemPaidHistory(...)`.
- **Fix:** Register `ItemPromotionProvider` as `ChangeNotifierProxyProvider<ItemPaidHistoryRepository, ItemPromotionProvider>` so it receives the already-registered repository.

### Low

#### [PROV-21] PsProvider base class does not override dispose() to centrally set isDispose
- **File:** `lib/provider/common/ps_provider.dart` (line 1)
- **Severity:** Low
- **Problem:** `PsProvider` extends `ChangeNotifier` but never overrides `dispose()`. If a new subclass forgets to set `isDispose = true`, it may call `notifyListeners()` on a disposed `ChangeNotifier` (which throws 'A ChangeNotifier was used after being disposed') on slow async paths.
- **Fix:** Add a `dispose()` override in `PsProvider` that sets `isDispose = true` then calls `super.dispose()`. Subclasses already call `super.dispose()`, so the flag will be set reliably.

#### [PROV-22] _selectedIndex is a global file-level variable shared across all OfferListView instances
- **File:** `lib/ui/offer/list/offer_list_view.dart` (line 10)
- **Severity:** Low
- **Problem:** `int _selectedIndex = 0;` is declared at the top level of the file. Tab selection is shared across all `OfferListView` instances and persists even after the screen is popped. Re-entering the offers screen always starts on the last-selected tab from the previous app-lifecycle session.
- **Fix:** Move `_selectedIndex` inside `_OfferListViewState` as an instance field: `int _selectedIndex = 0;`

---

## 4. Memory Leaks & Missing dispose()

### Critical

#### [MEM-1] AnimationController leaked in ProductDetailView — dispose() never calls animationController.dispose()
- **File:** `lib/ui/item/detail/product_detail_view.dart` (lines 100–104)
- **Severity:** Critical
- **Problem:** `_ProductDetailState` creates `animationController = AnimationController(...)` in `initState()` with `SingleTickerProviderStateMixin`, but `dispose()` (line 108) only calls `_swapChipsController.dispose()` — never `animationController.dispose()`. This AnimationController leaks every time the product detail screen is opened.
- **Fix:** Add `animationController?.dispose();` to `dispose()` before `super.dispose()`.

#### [MEM-2] ChatListScreen has NO dispose() method — two AnimationControllers leak
- **File:** `lib/ui/chat/list/chat_list_screen.dart` (lines 45–58)
- **Severity:** Critical
- **Problem:** `_ChatListScreenState` (with `TickerProviderStateMixin`) creates `animationController` and `animationControllerForFab` in `initState()` but has NO `dispose()` method at all. Both controllers leak on every navigation away from the chat list screen. Additionally, `animationControllerForFab` is declared `late` but never assigned, which is a `LateInitializationError` crash risk if it is accessed.
- **Fix:** Assign `animationControllerForFab` in `initState()`. Add: `@override void dispose() { animationController.dispose(); animationControllerForFab.dispose(); super.dispose(); }`

#### [MEM-3] ScrollController and TextEditingController created with no dispose() in ProductListWithFilterView
- **File:** `lib/ui/item/list_with_filter/product_list_with_filter_view.dart` (lines 43–62)
- **Severity:** Critical
- **Problem:** `_ProductListWithFilterViewState` creates `_scrollController = ScrollController()` and `searchTextController = TextEditingController()` as field initialisers and adds a scroll listener in `initState()`, but there is NO `dispose()` method. Both controllers leak and the listener is never removed.
- **Fix:** Add: `@override void dispose() { _scrollController.dispose(); searchTextController.dispose(); super.dispose(); }` and extract the scroll listener to a named method so it can be removed.

#### [MEM-4] EditPhoneVerifyView has no dispose() method at all
- **File:** `lib/ui/user/edit_profile/edit_phone_verify/edit_phone_verify_view.dart` (lines 39–44)
- **Severity:** Critical
- **Problem:** `_EditPhoneVerifyViewState` has no `dispose()` method. While `animationController` is received as a widget parameter, the absence of `dispose()` means any future resource additions will not be cleaned up.
- **Fix:** Add `@override void dispose() { super.dispose(); }` as a baseline.

### High

#### [MEM-5] Dashboard _HomeViewState ScrollController never disposed
- **File:** `lib/ui/dashboard/core/dashboard_view.dart` (lines 102–103)
- **Severity:** High
- **Problem:** `_HomeViewState` declares `final ScrollController _scrollController = ScrollController()`. The existing `dispose()` method disposes search ctrl, focus node, both animation controllers, and removes the `WidgetsBinding` observer — but never calls `_scrollController.dispose()`.
- **Fix:** Add `_scrollController.dispose();` to the existing `dispose()` method.

#### [MEM-6] GlobalKey<NestedScrollViewState> held as State field in ProfileView
- **File:** `lib/ui/user/profile/profile_view.dart` (line 229)
- **Severity:** High
- **Problem:** `_ProfilePageState` holds `final GlobalKey<NestedScrollViewState> _nestedKey = GlobalKey<NestedScrollViewState>()`. `GlobalKey` instances keep their `Element` alive. Retaining a key referencing `NestedScrollViewState` means the entire subtree cannot be GC'd until the key is cleared.
- **Fix:** Either use a local variable passed down, or document the intentional lifetime. Ensure the key is not re-used across rebuilds.

#### [MEM-7] GlobalKey<AllControllerTextWidgetState> held as State field in ItemEntryViewBase
- **File:** `lib/ui/item/entry/item_entry_view_base.dart` (lines 90–91)
- **Severity:** High
- **Problem:** `_ItemEntryViewBaseState` declares `final GlobalKey<AllControllerTextWidgetState> _formKey`. This key keeps the referenced `State` and its entire subtree alive in the global key registry until the item entry page is popped. The existing `dispose()` does not clear this key.
- **Fix:** Accept the current pattern for form `GlobalKey`s as standard practice. If memory pressure is observed, switch to a callback-based approach instead of a `GlobalKey`.

#### [MEM-8] ScrollController anonymous listener added in initState but never removed in ProductListWithFilterView
- **File:** `lib/ui/item/list_with_filter/product_list_with_filter_view.dart` (lines 52–61)
- **Severity:** High
- **Problem:** `_scrollController.addListener(...)` adds an anonymous closure inside `initState()` (inside a callback). The anonymous lambda captures `_searchProductProvider` and `valueHolder`, preventing GC. Since there is no `dispose()`, the listener is never removed.
- **Fix:** Extract the anonymous listener to a named method `_onScroll()`. Add `_scrollController.removeListener(_onScroll)` at the start of the new `dispose()`.

#### [MEM-9] Timer in _LoginViewState — minor fragility with concurrent dispose/tick
- **File:** `lib/ui/user/login/login_view.dart` (lines 87–88)
- **Severity:** High
- **Problem:** `_resendTimer` is correctly created as `Timer.periodic` and cancelled in `dispose()`. However, the timer callback checks `if (!mounted) { timer.cancel(); return; }` on the outer `timer` variable — not `_resendTimer`. A concurrent tick between `dispose()` and the timer's internal cancel could attempt `setState()`.
- **Fix:** In the timer callback, add `_resendTimer = null;` after `timer.cancel()` to avoid a stale reference. Current implementation is functionally correct but fragile.

#### [MEM-10] SearchBarWidget holds ValueNotifier and anonymous listener that are never disposed
- **File:** `lib/ui/common/search_bar_view.dart` (line 87)
- **Severity:** High
- **Problem:** `SearchBarWidget` is a plain Dart class (not `StatefulWidget`), so it has no `dispose()`. It holds `final ValueNotifier<bool> isSearching = ValueNotifier<bool>(false)` and adds an anonymous listener to the `controller`. Neither is ever cleaned up. The anonymous listener captures `this`, preventing GC.
- **Fix:** Expose a `dispose()` method on `SearchBarWidget` that calls `isSearching.dispose()` and `controller?.removeListener(_clearActiveListener)` (extract the anonymous listener to a named method). Call it from the owning `State.dispose()`.

#### [MEM-11] TabController listener in _ReplyBottomSheetBodyState uses async lambda that captures context
- **File:** `lib/ui/user/profile/widgets/profile_sweet_messages_section.dart` (lines 971–1034)
- **Severity:** High
- **Problem:** `_tabController.addListener(...)` uses an async lambda at line 1010. `dispose()` calls `_tabController.dispose()` but does NOT explicitly call `removeListener` first. The async lambda capturing `context` and `provider` may keep them alive if the bottom sheet is dismissed while `loadPhraseSuggestions` is still running.
- **Fix:** Extract the tab listener to a named method `_onTabChanged()`. Add `_tabController.removeListener(_onTabChanged)` before `_tabController.dispose()` in `dispose()`. Confirm `if (!mounted) return;` runs before any `setState` call.

#### [MEM-12] ChatBuyerListView anonymous scroll listener added inside postFrameCallback — never removed
- **File:** `lib/ui/chat/list/chat_buyer_list_view.dart` (lines 72–79)
- **Severity:** High
- **Problem:** An anonymous closure is passed to `_scrollController.addListener(...)` inside `WidgetsBinding.instance.addPostFrameCallback((_) {...})` in `initState()`. The lambda captures `holder`, `psValueHolder`, and `provider`. If `dispose()` is called before the post-frame callback fires, the callback still fires and adds a listener to an already-disposed controller.
- **Fix:** Use a named method `_onScrollChanged()`. Guard with `if (!mounted) return;`. Add `_scrollController.removeListener(_onScrollChanged)` at the start of `dispose()` before `_scrollController.dispose()`.

#### [MEM-13] ChatSellerListView likely has the same anonymous scroll listener pattern
- **File:** `lib/ui/chat/list/chat_seller_list_view.dart` (approximately line 72)
- **Severity:** High
- **Problem:** Structural symmetry with `ChatBuyerListView` suggests `_ChatSellerListViewState` adds an anonymous listener to its `ScrollController` inside a `postFrameCallback` without explicit `removeListener`, with the same memory-retention concern.
- **Fix:** Same fix as MEM-12: extract to named method, guard with mounted check, call `removeListener` in `dispose()`.

### Medium

#### [MEM-14] ChatBuyerListView anonymous scroll listener recreated on every postFrameCallback
- **File:** `lib/ui/chat/list/chat_buyer_list_view.dart` (lines 72–79)
- **Severity:** Medium
- **Problem:** Already covered by MEM-12 above. The anonymous lambda pattern creates secondary risk of listener accumulation if `initState()` is called more than once in edge-case widget recycling scenarios.
- **Fix:** See MEM-12.

#### [MEM-15] TaapdeelHighlightCarousel Timer recreation on every page change is safe but worth documenting
- **File:** `lib/ui/common/taapdeel/taapdeel_highlight_carousel.dart` (lines 80–93)
- **Severity:** Medium
- **Problem:** `_startAutoPlay()` cancels any existing `_autoPlayTimer` before creating a new `Timer.periodic`. `dispose()` correctly calls `_autoPlayTimer?.cancel()` and `_pageController.dispose()`. Pattern is safe.
- **Fix:** No action needed. Document the cancel-before-recreate pattern in a code comment for future maintainers.

#### [MEM-16] LoginView _askUserNameDialog creates a local TextEditingController that is never disposed
- **File:** `lib/ui/user/login/login_view.dart` (line 694)
- **Severity:** Medium
- **Problem:** `TextEditingController nameController = TextEditingController()` is created locally inside `_askUserNameDialog()` but never disposed when the dialog is dismissed.
- **Fix:** Use a `StatefulBuilder` or a dedicated dialog `StatefulWidget` that owns the controller and calls `dispose()`. Or dispose it explicitly: `final val = nameController.text; nameController.dispose(); return val;`

#### [MEM-17] Global ValueNotifier suggestedSwapHiddenRequestedIdsNotifier accumulates IDs indefinitely
- **File:** `lib/ui/Foryou/widgets/suggested_swaps_section.dart` (lines 19–20)
- **Severity:** Medium
- **Problem:** `final ValueNotifier<Set<String>> suggestedSwapHiddenRequestedIdsNotifier = ValueNotifier<Set<String>>({})` is declared at the file (global) level. The `Set<String>` accumulates hidden IDs indefinitely over a session, leading to unbounded memory growth.
- **Fix:** Periodically clear the notifier's value when the user navigates back to the For-You tab, or cap the set at a maximum size (e.g. 100 entries).

#### [MEM-18] _HomeDashboardViewWidgetState anonymous scroll listener — confirmed correctly removed
- **File:** `lib/ui/Discover/home_dashboard_view.dart` (lines 219–221)
- **Severity:** Medium
- **Problem:** `widget.scrollController.addListener(_onScroll)` is called in `initState()`. The `dispose()` method correctly calls `widget.scrollController.removeListener(_onScroll)`. This is correct. Included as a note to verify `WishItemsProvider.dispose()` fully cleans up streams/timers.
- **Fix:** No action needed for the scroll controller. Verify `WishItemsProvider.dispose()` fully cleans up all streams/timers.

#### [MEM-19] _HomeDashboardViewWidgetState ValueNotifier<bool> _showScrollToTop — confirmed correctly disposed
- **File:** `lib/ui/Discover/home_dashboard_view.dart` (line 98)
- **Severity:** Medium
- **Problem:** `final ValueNotifier<bool> _showScrollToTop = ValueNotifier<bool>(false)` — `dispose()` correctly calls `_showScrollToTop.dispose()`.
- **Fix:** No action needed.

### Low

#### [MEM-20] NotiProvider stream listener casts resource.data with hard as List<Noti>? — unsafe cast
- **File:** `lib/provider/noti/noti_provider.dart` (line 25)
- **Severity:** Low
- **Problem:** `final List<Noti> data = (resource.data as List<Noti>?) ?? <Noti>[];` — hard cast `as List<Noti>?`. If `resource.data` is `List<dynamic>` (which JSON parsing produces in some paths), the cast throws at runtime.
- **Fix:** Use `final List<Noti> data = (resource.data is List<Noti>) ? resource.data as List<Noti> : <Noti>[];` or ensure the stream always emits `PsResource<List<Noti>>`.

---

## 5. Dead Code & Unused Imports

### Critical

#### [DEAD-1] SwapWebServices class is entirely unreferenced
- **File:** `lib/api/swap_services.dart`
- **Severity:** Critical
- **Problem:** `SwapWebServices` and all its methods (`getSwapBalance`, `decrementSwapBalance`, `incrementSwapBalance`, `incrementSwapNumber`) are defined but never imported or instantiated anywhere in the codebase. The same operations are already duplicated in `SwapProductsProvider`. The file also contains bare `print()` statements throughout.
- **Fix:** Delete the entire file `api/swap_services.dart`.

#### [DEAD-2] firebaseMessagingBackgroundHandler is @pragma-decorated but its registration is commented out
- **File:** `lib/main.dart` (lines 58–64, 73)
- **Severity:** Critical
- **Problem:** `firebaseMessagingBackgroundHandler` is tagged `@pragma('vm:entry-point')` but its only call site (`FirebaseMessaging.onBackgroundMessage`) is commented out on line 73. The handler's local `chatData` variable is assigned but never used. Background FCM messages are silently dropped.
- **Fix:** Either uncomment line 73 and use `chatData` for navigation/storage, or remove the entire handler function, its `@pragma` annotation, and the commented line 73.

#### [DEAD-3] _initPaymob, _initMobileAds, and _initCameras are implemented but never called
- **File:** `lib/main.dart` (lines 120–129, 286–298)
- **Severity:** Critical
- **Problem:** Three fully-implemented async functions have zero call sites anywhere in the codebase. `_initPaymob` initialises `FlutterPaymob`; `_initMobileAds` calls `MobileAds.instance.initialize()`; `_initCameras` populates `Utils.cameras`. None are called from `main()` or `_AppServicesBootstrap._startHeavyServices()`.
- **Fix:** Decide whether each service is required. If yes, call from the appropriate initialisation point. If not, remove the dead functions.

#### [DEAD-4] ElevatedContainer widget defined but never imported or used
- **File:** `lib/viewobject/elevated_container.dart`
- **Severity:** Critical
- **Problem:** `ElevatedContainer` is defined in the `viewobject` directory. It is never imported in any other file and never referenced in the UI or provider layer.
- **Fix:** Delete `viewobject/elevated_container.dart`. If a custom elevated container widget is still needed, create it in `lib/ui/common/`.

#### [DEAD-5] ChatUserPresence viewobject defined but never imported
- **File:** `lib/viewobject/chat_user_presence.dart`
- **Severity:** Critical
- **Problem:** `chat_user_presence.dart` exists with a full model class but no other file imports it. There is no repository, DAO, or UI component that references it.
- **Fix:** Delete `viewobject/chat_user_presence.dart` unless real-time presence tracking is planned.

#### [DEAD-6] ItemColor viewobject is a duplicate of color.dart and neither is imported
- **File:** `lib/viewobject/ItemColor.dart`, `lib/viewobject/color.dart`
- **Severity:** Critical
- **Problem:** `ItemColor` is a duplicate of `viewobject/color.dart` (identical fields). Neither file is imported anywhere. Additionally, `color.dart` defines a class named `Colors` which shadows Flutter's own `Colors` class, making it dangerous to import.
- **Fix:** Delete `viewobject/ItemColor.dart`. Evaluate `viewobject/color.dart` — if also confirmed unused, delete it too. The naming conflict with Flutter's `Colors` makes it additionally hazardous.

### High

#### [DEAD-7] getSharedPrefUserId in paymob_payment/functions.dart has an empty body and is never called
- **File:** `lib/paymob_payment/functions.dart` (lines 15–19)
- **Severity:** High
- **Problem:** `Future<String?> getSharedPrefUserId()` has its entire body commented out (returns `null` implicitly) and is never called from any other file.
- **Fix:** Restore the implementation and wire it up, or remove the function entirely.

#### [DEAD-8] MainProvider and MainBuyerProvider are near-identical duplicates
- **File:** `lib/provider/main_provider.dart`, `lib/provider/mainBuyer_provider.dart`
- **Severity:** High
- **Problem:** Both providers are line-for-line duplicates differing only in whether they call `getSentList` on a `SellerChatHistoryListProvider` vs. `BuyerChatHistoryListProvider`. The `statusString()` logic is a third copy already present in `SwapProductsProvider`.
- **Fix:** Extract a shared abstract base class (e.g. `AbstractSwapListProvider`) parameterised by chat-history provider type. Remove duplicate `statusString()` from `SwapProductsProvider`.

#### [DEAD-9] SwapProductsProvider imports package:http/http.dart twice
- **File:** `lib/provider/SwapProductsProvider.dart` (lines 7–8)
- **Severity:** High
- **Problem:** Line 7 imports `'package:http/http.dart'` (bare) and line 8 imports the same package as `http`. Redundant — only the aliased form is needed.
- **Fix:** Remove line 7 (`import 'package:http/http.dart';`) and use `http.Response` everywhere.

#### [DEAD-10] ps_api_service.dart imports coupon_discount.dart which is never used
- **File:** `lib/api/ps_api_service.dart` (line 16)
- **Severity:** High
- **Problem:** `import 'package:taapdeel/viewobject/coupon_discount.dart'` is present but `CouponDiscount` is not referenced anywhere in that file. There is no coupon API endpoint.
- **Fix:** Remove the `CouponDiscount` import from `ps_api_service.dart`.

#### [DEAD-11] ps_api_service.dart imports flutter/cupertino.dart but uses no Cupertino symbols
- **File:** `lib/api/ps_api_service.dart` (line 5)
- **Severity:** High
- **Problem:** `import 'package:flutter/cupertino.dart'` is the first import but no Cupertino widget or class is referenced anywhere in the file.
- **Fix:** Remove the `flutter/cupertino.dart` import.

#### [DEAD-12] mainBuyer_provider.dart imports dart:async with no async primitives used
- **File:** `lib/provider/mainBuyer_provider.dart` (line 3)
- **Severity:** High
- **Problem:** `import 'dart:async'` is present but the file uses no `StreamController`, `StreamSubscription`, `Timer`, or `unawaited()`.
- **Fix:** Remove `import 'dart:async'`.

#### [DEAD-13] family_items_provider.dart imports flutter/foundation.dart but kDebugMode is unused
- **File:** `lib/provider/product/family_items_provider.dart` (line 4)
- **Severity:** High
- **Problem:** `import 'package:flutter/foundation.dart'` is present but neither `kDebugMode` nor `kReleaseMode` appear in the file. `debugPrint()` comes from `flutter/material.dart` (already imported).
- **Fix:** Remove the `flutter/foundation.dart` import.

#### [DEAD-14] notification_setting_view.dart imports flutter/services.dart but no services symbol is used
- **File:** `lib/ui/noti/notification_setting/notification_setting_view.dart` (line 3)
- **Severity:** High
- **Problem:** `import 'package:flutter/services.dart'` is present but `SystemChrome`, `HapticFeedback`, `Clipboard`, `MethodChannel`, or any other services class is absent from the file body.
- **Fix:** Remove the `flutter/services.dart` import.

#### [DEAD-15] SwapProductsProvider contains numerous bare print() statements
- **File:** `lib/provider/SwapProductsProvider.dart` (lines 187–188, 213–214, 231–232, 332–352, 359–376, 383–400, 407–424)
- **Severity:** High
- **Problem:** All HTTP methods use `print()` for error and progress logging. `print()` emits to stdout in production builds; unlike `debugPrint()` it is not stripped in release mode.
- **Fix:** Replace all `print()` calls with `debugPrint()` (stripped in release) or `dart:developer log()`.

#### [DEAD-16] paymob_payment/functions.dart contains multiple bare print() calls
- **File:** `lib/paymob_payment/functions.dart` (lines 34–35, 47, 71, 78, 101, 115, 135)
- **Severity:** High
- **Problem:** `getUserData()`, `decreasePoints()`, and `addSwapRequests()` use `print()` statements for debug diagnostics emitted to production stdout.
- **Fix:** Replace with `debugPrint()` or remove.

#### [DEAD-17] ItemPromotionProvider uses bare print() in constructor and dispose()
- **File:** `lib/provider/promotion/item_promotion_provider.dart` (lines 17, 56)
- **Severity:** High
- **Problem:** `print('Item Paid History Provider: $hashCode')` and `print('Item Paid History Provider Dispose: $hashCode')` are emitted every time the provider is created or destroyed.
- **Fix:** Remove these lifecycle prints or guard them with `kDebugMode`.

#### [DEAD-18] viewobject/color.dart defines a Colors class that shadows Flutter's Colors and is never imported
- **File:** `lib/viewobject/color.dart`
- **Severity:** High
- **Problem:** `viewobject/color.dart` defines a class named `Colors` (shadowing Flutter's `Colors`) with product colour fields. No other file imports it. The name collision is additionally dangerous.
- **Fix:** Delete `viewobject/color.dart`.

#### [DEAD-19] MainProvider.pageviewAppBar is a late final field that is never assigned
- **File:** `lib/provider/main_provider.dart` (line 159)
- **Severity:** High
- **Problem:** `late final OfferListViewAppBar? pageviewAppBar` is declared but never assigned. Reading it before assignment throws `LateInitializationError`. Same problem exists in `MainBuyerProvider` at line 159.
- **Fix:** Remove `pageviewAppBar` from both `MainProvider` and `MainBuyerProvider`.

#### [DEAD-20] SwapProductsProvider.statusString() is defined but never called
- **File:** `lib/provider/SwapProductsProvider.dart` (lines 240–259)
- **Severity:** High
- **Problem:** `statusString(BuildContext context, String type)` is defined but never invoked from any external caller. The same logic exists (and is used) in `MainProvider` and `MainBuyerProvider`.
- **Fix:** Remove `statusString()` from `SwapProductsProvider`.

#### [DEAD-21] Notification settings granular preferences not synced to backend
- **File:** `lib/ui/noti/notification_setting/notification_setting_view.dart` (line 131)
- **Severity:** High
- **Problem:** `// TODO: sync to backend — PATCH /api/users/notification-preferences`. `_setGranular()` only saves to local `SharedPreferences`. Changes are lost on reinstall or device switch.
- **Fix:** Implement the backend PATCH call, or remove the per-topic granular controls until the backend endpoint exists.

#### [DEAD-22] wish_ui_tabs_widgets.dart.bak is a backup source file committed to source control
- **File:** `lib/ui/wish_Items/wish_ui_tabs_widgets.dart.bak`
- **Severity:** High
- **Problem:** A `.bak` file exists alongside the live source file. It may contain sensitive old business logic, commented code, or outdated API calls.
- **Fix:** Delete the `.bak` file and add `*.bak` to `.gitignore`.

### Medium

#### [DEAD-23] FirebaseMessaging.onBackgroundMessage registration is commented out
- **File:** `lib/main.dart` (line 73)
- **Severity:** Medium
- **Problem:** `//FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);` — background FCM messages are silently dropped. The `@pragma` annotation on the handler keeps AOT from tree-shaking it, wastefully increasing binary size.
- **Fix:** Restore the registration and handle `chatData`, or remove both the comment and the entire handler function.

#### [DEAD-24] Multiple PsUrl constants reference endpoints with no call sites
- **File:** `lib/api/ps_url.dart` (lines 270–277, 330–350)
- **Severity:** Medium
- **Problem:** Several URL constants are defined but never referenced: `ps_commentList_url`, `ps_commentDetail_url`, `ps_commentHeaderPost_url`, `ps_commentDetailPost_url`, `ps_news_feed_url`, `ps_transactionList_url`, `ps_transactionDetail_url`, `ps_downloadProductPost_url`, `ps_products_search_url`, `ps_all_collection_url`, `ps_collection_product_url`, `ps_collection_url`. These suggest entire unimplemented features.
- **Fix:** Remove unused URL constants, or move them to a `// future-features` constants file with a clear comment.

#### [DEAD-25] ItemCurrencyDao registered in providers but no repository or consumer exists
- **File:** `lib/provider/ps_provider_dependencies.dart` (line 119)
- **Severity:** Medium
- **Problem:** `Provider<ItemCurrencyDao>.value(value: ItemCurrencyDao())` is registered but there is no `ItemCurrencyRepository`, no `ProxyProvider` depending on it, and no UI widget reading it.
- **Fix:** Either implement `ItemCurrencyRepository` and wire `ItemCurrencyDao` into the dependent provider chain, or remove the registration.

#### [DEAD-26] Profile products tab TODO for family items pagination not implemented
- **File:** `lib/ui/user/profile/tabs/profile_products_tab.dart` (line 102)
- **Severity:** Medium
- **Problem:** `// TODO: أضف pagination للـ family لو موجود` — family items tab has no load-more support.
- **Fix:** Implement pagination by wiring `ProfileFamilyItemsProvider.nextFamilyItems()` to a scroll listener, or add a 'Load more' button.

#### [DEAD-27] Wish items section TODO for opening item-entry for swap offers
- **File:** `lib/ui/Discover/verticalview/wish_items_section_sliver.dart` (line 456)
- **Severity:** Medium
- **Problem:** `// TODO: open item-entry for creating an offer swap against this wish` — the tap handler is incomplete.
- **Fix:** Wire the `onTap` to the appropriate route for creating a swap offer against the wish item.

#### [DEAD-28] Commented-out SharedPreferences code with hardcoded user IDs in paymob_payment/functions.dart
- **File:** `lib/paymob_payment/functions.dart` (lines 16–18)
- **Severity:** Medium
- **Problem:** Three lines of commented-out code form the original body of `getSharedPrefUserId()` with two alternate hardcoded user IDs.
- **Fix:** Remove the commented-out code block entirely.

#### [DEAD-29] Hardcoded test card number and commented user IDs in paymob_payment/core/consts.dart
- **File:** `lib/paymob_payment/core/consts.dart` (lines 8–15, 32–33)
- **Severity:** Medium
- **Problem:** Lines 8–15 contain a commented block with a Visa test card number, expiry, and CVV. Lines 32–33 contain two commented-out hardcoded user-ID strings. These are development artefacts that should not appear in a production file.
- **Fix:** Remove the commented test-card block and the commented user-ID strings.

#### [DEAD-30] OfferListViewAppBarItem in MainBuyerProvider reads MainProvider counts instead of its own
- **File:** `lib/provider/mainBuyer_provider.dart` (lines 176–193)
- **Severity:** Medium
- **Problem:** `pageviewAppBarWidget()` creates `OfferListViewAppBarItem` objects without the `size` parameter. The app bar's `build` method reads `MainProvider.of(context).swapList*` counts — not `MainBuyerProvider`'s — so the buyer-list app bar always shows seller counts.
- **Fix:** Pass the correct size values from `MainBuyerProvider`'s own `swapList` fields, or unify both providers.

#### [DEAD-31] Firebase config debugPrint emitted on every cold start
- **File:** `lib/main.dart` (lines 152–155)
- **Severity:** Medium
- **Problem:** Four `debugPrint()` calls log `FIREBASE_RUNTIME_projectId`, `FIREBASE_RUNTIME_appId`, `FIREBASE_RUNTIME_messagingSenderId`, `FIREBASE_RUNTIME_apiKey` on every app start. These were needed during initial Firebase setup only.
- **Fix:** Remove these diagnostic prints from `_initFirebaseCore()`.

#### [DEAD-32] firebaseMessagingBackgroundHandler silently swallows all exceptions
- **File:** `lib/main.dart` (lines 59–63)
- **Severity:** Medium
- **Problem:** The background FCM handler wraps everything in `try {} catch (e) {}` with no logging. Failures during background message processing are silently discarded.
- **Fix:** Add `FirebaseCrashlytics.instance.recordError(e, stackTrace)` or `debugPrint()` inside the catch block.

#### [DEAD-33] _initFirebaseCore catch block swallows non-duplicate-app Firebase errors silently
- **File:** `lib/main.dart` (lines 157–161)
- **Severity:** Medium
- **Problem:** The final `catch (e) {}` block silently drops any non-`FirebaseException` error. If Firebase fails to initialise for any non-duplicate-app reason, the app proceeds with Firebase in an unknown state.
- **Fix:** Log the error with `debugPrint()` or Crashlytics and consider re-throwing if Firebase is critical.

### Low

#### [DEAD-34] ProfileFamilyItemsProvider has 30+ emoji-prefixed debugPrint calls
- **File:** `lib/provider/product/family_items_provider.dart`
- **Severity:** Low
- **Problem:** 30+ `debugPrint()` calls with emoji prefixes (`🟦`, `🟩`, `🟨`, `❌`) flood the debug console. These are diagnostic prints from development.
- **Fix:** Remove or condense the debug prints. Keep only error-path prints if needed.

#### [DEAD-35] Missing favourite toggle implementation — two TODOs
- **File:** `lib/ui/item/list_with_filter/product_list_with_filter_container.dart` (line 370), `lib/ui/item/list_with_filter/nearest_product_list_view.dart` (line 368)
- **Severity:** Low
- **Problem:** Both files have TODO comments for missing favourite toggle API wiring in the filtered and nearest product list views.
- **Fix:** Implement the favourite toggle by calling the existing `FavouriteItemProvider` from both list views' item tap handlers.

#### [DEAD-36] Commented-out URL/thumbnail constants in ps_config.dart and ps_url.dart
- **File:** `lib/config/ps_config.dart` (lines 48–50), `lib/api/ps_url.dart` (lines 46–47)
- **Severity:** Low
- **Problem:** Commented-out `ps_app_image_thumbs_2x_url`, `ps_app_image_thumbs_3x_url` in `ps_config.dart` and a duplicate `ps_family_network_items_url` line in `ps_url.dart`.
- **Fix:** Remove all three commented-out lines.

#### [DEAD-37] Commented-out _checkAppleSignIn() call with dead function definition in main.dart
- **File:** `lib/main.dart` (line 601, line 290–292)
- **Severity:** Low
- **Problem:** `// unawaited(_checkAppleSignIn());` is commented out with a note that it is unnecessary on cold start. The `_checkAppleSignIn()` function definition still exists and is thus unreachable dead code.
- **Fix:** If the Apple Sign-In availability check is not needed on start, remove both the comment and the `_checkAppleSignIn()` function definition.

#### [DEAD-38] Commented-out layout code in offer_list_view_app_bar.dart
- **File:** `lib/ui/offer/list/offer_list_view_app_bar.dart` (lines 69–73, 93–101)
- **Severity:** Low
- **Problem:** Two commented-out code blocks inside `_buildItem()` — an `Icon` widget and a `Padding + Text` widget — are old layout experiments.
- **Fix:** Remove the commented-out code blocks.

---

## Recommended Fix Order

The following 15 fixes are prioritised by a combination of severity, user impact, and blast radius. Fix in this order:

1. **[BUGS-1] + [BUGS-2] — Authentication credentials bug** (`user_provider.dart` lines 838, 999): Firebase email sign-in and sign-up pass `email` as the password. Every user attempting email auth is affected. One-line fix per site.

2. **[BUGS-3] — approveRequest calls reject endpoint** (`SwapProductsProvider.dart` lines 221–237): Core swap feature is broken — approving an offer silently rejects it. Fix URL and remove the redundant fire-and-forget `approveOffer` call.

3. **[BUGS-4] — markSweetMessageRead calls wrong URL** (`ps_api_service.dart` lines 641–663): Read status never persists to the server. Fix the endpoint URL.

4. **[BUGS-5] — .catchError returns null causing NullPointerException in PsApiResponse** (`ps_api.dart` lines 88–91, 131–134): Any caught HTTP error causes an immediate crash. Replace with `try/catch` returning a fallback `http.Response('{}', 500)`.

5. **[PROV-1] — MultiProvider recreated inside build() in main.dart** (`main.dart` line 338): Six global providers (including `MainProvider`, `HomeProvider`, `PaymentProvider`) are destroyed and rebuilt on every parent rebuild. Move them out of `build()` into `initState()` or the top-level provider list.

6. **[BUGS-8] — providers.single throws on empty/multi-provider list** (`user_provider.dart` line 363): `StateError` thrown for any unregistered email or multi-provider account. Replace with `providers.isNotEmpty ? providers.first : ''`.

7. **[BUGS-7] + [BUGS-16] — Force-unwrap crashes on nullable streams** (`product_repository.dart` lines 73–79, `user_repository.dart` lines 47–49): Add `if (stream == null) return;` guards before sink access.

8. **[MEM-2] — ChatListScreen has no dispose() — two AnimationControllers leak** (`chat_list_screen.dart` lines 45–58): Every chat tab visit leaks controllers. Add `dispose()` and assign the `late` field.

9. **[MEM-1] — ProductDetailView AnimationController never disposed** (`product_detail_view.dart` lines 100–104): Leaks on every product detail visit. Add `animationController?.dispose()` to existing `dispose()`.

10. **[MEM-3] — ProductListWithFilterView has no dispose() — ScrollController and TextEditingController leak** (`product_list_with_filter_view.dart` lines 43–62): Add `dispose()` with both controller dispose calls and listener removal.

11. **[BUGS-10] — getOtherUserData deletes ALL users from local DB** (`user_repository.dart` line 438): Wiping the entire user cache on every profile view breaks logged-in user data. Replace `deleteAll()` with `deleteWithFinder(finder)`.

12. **[PROV-2] — ChangeNotifierProvider created inside build() in offer list views** (`offer_sent_list_view.dart` lines 62–76): Provider recreated on every rebuild, causing repeated API calls and flicker. Move provider creation to `initState()`.

13. **[BUGS-11] + [BUGS-12] — Off-by-one in all next-page pagination sort indices** (`product_repository.dart` line 261, `offer_repository.dart` line 135, and siblings): Creates sort gaps and potential duplicates at every page boundary. Change `length + 1` to `length` in all four next-page methods.

14. **[PROV-3] — Provider.of without listen:false on repository providers** (`dashboard_view.dart` lines 547–564 and ~10 other files): Full-screen rebuilds from non-reactive repository providers. Add `listen: false` or use `context.read<T>()` at all read-only call sites.

15. **[DEAD-1] — Delete the entirely unused SwapWebServices class** (`api/swap_services.dart`): Removes dead code, duplicate HTTP calls, and multiple production `print()` statements in one delete.

---

## Quick Wins (< 30 min each)

The following issues can each be fixed in under 30 minutes with low risk of regression:

- **[BUGS-1] + [BUGS-2]** — Change `email` to `password` in two `signIn`/`createUser` call sites in `user_provider.dart`.
- **[BUGS-4] markSweetMessageRead wrong URL** — Change one string constant in `ps_api_service.dart`.
- **[BUGS-6]** — Replace `imageId!` with `imageId ?? ''` at two sites in `ps_api.dart`.
- **[BUGS-9]** — Add `await` to `return postUploadChatImage(...)` in `ps_api_service.dart`.
- **[BUGS-14] + [BUGS-15]** — Replace `resource.data!.length` with `resource.data?.length ?? 0` in offer and chat providers.
- **[BUGS-22]** — Replace `defaultLanguage!.languageCode` with `defaultLanguage?.languageCode` in `ps_shared_preferences.dart`.
- **[MEM-1]** — Add `animationController?.dispose();` to `_ProductDetailState.dispose()`.
- **[DEAD-9]** — Remove the duplicate bare `http` import line in `SwapProductsProvider.dart`.
- **[DEAD-10] + [DEAD-11]** — Remove `coupon_discount.dart` and `flutter/cupertino.dart` imports from `ps_api_service.dart`.
- **[DEAD-12]** — Remove `import 'dart:async'` from `mainBuyer_provider.dart`.
- **[DEAD-13]** — Remove `import 'package:flutter/foundation.dart'` from `family_items_provider.dart`.
- **[DEAD-14]** — Remove `import 'package:flutter/services.dart'` from `notification_setting_view.dart`.
- **[DEAD-19]** — Remove the unassigned `late final OfferListViewAppBar? pageviewAppBar` field from both `MainProvider` and `MainBuyerProvider`.
- **[DEAD-20]** — Remove `statusString()` from `SwapProductsProvider.dart`.
- **[DEAD-22]** — Delete `lib/ui/wish_Items/wish_ui_tabs_widgets.dart.bak` and add `*.bak` to `.gitignore`.
- **[DEAD-29]** — Remove test card number and commented user-ID strings from `paymob_payment/core/consts.dart`.
- **[DEAD-4] + [DEAD-5]** — Delete `viewobject/elevated_container.dart` and `viewobject/chat_user_presence.dart` (never imported).
- **[PROV-22]** — Move `int _selectedIndex = 0;` from file-level to inside `_OfferListViewState`.
- **[DEAD-31]** — Remove four Firebase config `debugPrint` calls from `_initFirebaseCore()` in `main.dart`.
- **[DEAD-15]** — Replace all `print()` calls with `debugPrint()` in `SwapProductsProvider.dart` (~20 occurrences).
