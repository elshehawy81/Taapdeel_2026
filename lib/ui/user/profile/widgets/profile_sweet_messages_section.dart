import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/ps_config.dart';
import '../../../../viewobject/common/ps_value_holder.dart';
import '../../../sweet_phrase/sweet_message.dart';
import '../../../sweet_phrase/sweet_message_badge_provider.dart';
import '../../../sweet_phrase/sweet_message_profile_provider.dart';
import '../../../sweet_phrase/sweet_message_provider.dart';
import '../../../sweet_phrase/sweet_message_repository.dart';
import '../../../sweet_phrase/sweet_phrase.dart';

class ProfileSweetMessagesSection extends StatefulWidget {
  const ProfileSweetMessagesSection({
    Key? key,
    required this.psValueHolder,
    this.autoRotateSeconds = 6,
  });

  final PsValueHolder psValueHolder;
  final int autoRotateSeconds;

  @override
  State<ProfileSweetMessagesSection> createState() =>
      _ProfileSweetMessagesSectionState();
}

class _ProfileSweetMessagesSectionState
    extends State<ProfileSweetMessagesSection> {
  late final PageController _pageController;
  SweetMessageProfileProvider? _profileProvider;
  SweetMessageBadgeProvider? _badgeProvider;
  bool _timerStarted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final SweetMessageProfileProvider? provider = _profileProvider;

      final String loginUserId = widget.psValueHolder.loginUserId ?? '';
      if (provider == null || loginUserId.isEmpty || loginUserId == 'nologinuser') {
        return;
      }

      await provider.refreshAll(
        loginUserId: loginUserId,
        limit: 10,
      );

      if (mounted) {
        _startAutoRotateIfNeeded();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileProvider ??=
        Provider.of<SweetMessageProfileProvider>(context, listen: false);
    _badgeProvider ??=
        Provider.of<SweetMessageBadgeProvider>(context, listen: false);
  }

  void _startAutoRotateIfNeeded() {
    if (_timerStarted || !mounted) {
      return;
    }

    final SweetMessageProfileProvider? provider = _profileProvider;
    if (provider == null) {
      return;
    }

    provider.attachPageController(
      _pageController,
      autoRotateSeconds: widget.autoRotateSeconds,
    );
    _timerStarted = true;
  }

  Future<void> _markReadIfNeeded(SweetMessage? message) async {
    if (message == null) {
      return;
    }

    final String loginUserId = widget.psValueHolder.loginUserId ?? '';
    if (loginUserId.isEmpty || loginUserId == 'nologinuser' || !message.unread) {
      return;
    }

    final SweetMessageProfileProvider? provider = _profileProvider;
    if (provider == null) {
      return;
    }

    await provider.markAsRead(
      loginUserId: loginUserId,
      sweetMessageId: message.sweetMessageId,
    );

    if (mounted) {
      _badgeProvider?.decrementUnread();
    }
  }

  Future<void> _openReplySheetFor(SweetMessage? message) async {
    if (message == null) {
      return;
    }

    final String loginUserId = widget.psValueHolder.loginUserId ?? '';
    if (loginUserId.isEmpty || loginUserId == 'nologinuser') {
      return;
    }

    await _markReadIfNeeded(message);

    if (!mounted) {
      return;
    }

    await showSweetReplyBottomSheet(
      context: context,
      loginUserId: loginUserId,
      receiverUserId: message.senderUserId,
      receiverName: message.senderUserName.trim().isEmpty
          ? 'المستخدم'
          : message.senderUserName,
      itemId: message.itemId,
      relationType: message.relationType,
      initialCategory: message.messageCategory.toLowerCase() == 'joke'
          ? 'joke'
          : 'sweet',
    );
  }

  @override
  void dispose() {
    _profileProvider?.detachPageController();
    _profileProvider = null;
    _badgeProvider = null;

    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SweetMessageProfileProvider>(
      builder: (_, SweetMessageProfileProvider provider, __) {
        final bool hidden = !provider.isLoadingMessages &&
            provider.messages.isEmpty &&
            provider.errorMessage.isEmpty;

        if (hidden) {
          return const SizedBox.shrink();
        }

        final SweetMessage? currentMessage = provider.currentMessage;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFFF9FCFF),
                Color(0xFFEFF7FF),
              ],
            ),
            border: Border.all(
              color: const Color(0xFFD8E9FB),
              width: 1.15,
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x120E2A47),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              _SectionHeader(
                unreadCount: provider.unreadCount,
                onMoreTap: () {},
                onSendTap: currentMessage == null
                    ? null
                    : () => _openReplySheetFor(currentMessage),
              ),
              const SizedBox(height: 14),
              if (provider.isLoadingMessages)
                const _LoadingCard()
              else if (provider.errorMessage.isNotEmpty)
                _ErrorCard(
                  message: provider.errorMessage,
                  onRetry: () async {
                    final String loginUserId =
                        widget.psValueHolder.loginUserId ?? '';
                    if (loginUserId.isEmpty || loginUserId == 'nologinuser') {
                      return;
                    }

                    await provider.refreshAll(
                      loginUserId: loginUserId,
                      limit: 10,
                    );
                  },
                )
              else
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 228,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          NotificationListener<ScrollStartNotification>(
                            onNotification: (_) {
                              provider.pauseAutoRotate();
                              return false;
                            },
                            child: NotificationListener<ScrollEndNotification>(
                              onNotification: (_) {
                                if (mounted && _pageController.hasClients) {
                                  provider.resumeAutoRotate(
                                    autoRotateSeconds: widget.autoRotateSeconds,
                                  );
                                }
                                return false;
                              },
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: provider.messages.length,
                                onPageChanged: (int index) async {
                                  provider.setCurrentIndex(index);
                                  await _markReadIfNeeded(provider.currentMessage);
                                },
                                itemBuilder: (_, int index) {
                                  final SweetMessage msg =
                                  provider.messages[index];

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: _SweetMessageCard(
                                      message: msg,
                                      isActive:
                                      provider.currentIndex == index,
                                      onTap: () async {
                                        await _markReadIfNeeded(msg);
                                      },
                                      onReplyTap: () async {
                                        await _openReplySheetFor(msg);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (provider.messages.length > 1)
                            PositionedDirectional(
                              start: -2,
                              child: _ArrowButton(
                                icon: Icons.chevron_left_rounded,
                                onTap: () {
                                  provider.pauseAutoRotate();
                                  provider.goPrevious();
                                  if (mounted && _pageController.hasClients) {
                                    _pageController.animateToPage(
                                      provider.currentIndex,
                                      duration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                    provider.resumeAutoRotate(
                                      autoRotateSeconds:
                                      widget.autoRotateSeconds,
                                    );
                                  }
                                },
                              ),
                            ),
                          if (provider.messages.length > 1)
                            PositionedDirectional(
                              end: -2,
                              child: _ArrowButton(
                                icon: Icons.chevron_right_rounded,
                                onTap: () {
                                  provider.pauseAutoRotate();
                                  provider.goNext();
                                  if (mounted && _pageController.hasClients) {
                                    _pageController.animateToPage(
                                      provider.currentIndex,
                                      duration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                    provider.resumeAutoRotate(
                                      autoRotateSeconds:
                                      widget.autoRotateSeconds,
                                    );
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DotsIndicator(
                      count: provider.messages.length,
                      currentIndex: provider.currentIndex,
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.unreadCount,
    required this.onMoreTap,
    required this.onSendTap,
  });

  final int unreadCount;
  final VoidCallback onMoreTap;
  final VoidCallback? onSendTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF4FACFE),
                Color(0xFF00F2FE),
              ],
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x220FA7B5),
                blurRadius: 14,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: const Icon(
            Icons.mark_email_unread_outlined,
            size: 20,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'رسائل لطيفة وصلتك',
                style: TextStyle(
                  fontSize: 15.2,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF162334),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


class _SweetMessageCard extends StatelessWidget {
  const _SweetMessageCard({
    required this.message,
    required this.isActive,
    required this.onTap,
    required this.onReplyTap,
  });

  final SweetMessage message;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onReplyTap;

  @override
  Widget build(BuildContext context) {
    final bool unread = message.unread;
    final bool isJoke = message.messageCategory.toLowerCase() == 'joke';

    final Color accent = isJoke ? const Color(0xFF213F96) : const Color(0xFF0C587A);
    final List<Color> cardGradient = isJoke
        ? const <Color>[
      Color(0xFF213F96),
      Color(0xFF172F78),
      Color(0xFF0E235F),
    ]
        : const <Color>[
      Color(0xFF061F46),
      Color(0xFF0C587A),
      Color(0xFF24A9C4),
      Color(0xFF29D6C7),
    ];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
          border: Border.all(
            color: unread ? accent.withOpacity(0.35) : const Color(0xFFE5ECF4),
            width: isActive ? 1.6 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: accent.withOpacity(isActive ? 0.20 : 0.08),
              blurRadius: isActive ? 24 : 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _AvatarCircle(
                  imageUrl: message.senderUserImage,
                  fallbackText: message.senderUserName,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message.senderUserName.isEmpty ? 'مستخدم' : message.senderUserName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1C2430),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  unread: unread,
                  category: message.messageCategory,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: cardGradient,
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.82),
                    width: 1.4,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: accent.withOpacity(0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.70),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                      child: Center(
                        child: Text(
                          message.messageText.isEmpty ? (isJoke ? 'تعليق خفيف' : 'رسالة لطيفة') : message.messageText,
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.4,
                            height: 1.65,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Color(0xFF8B97AA),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _formatDate(message.createdAt),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.2,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B97AA),
                    ),
                  ),
                ),
                _ReplyPillButton(
                  onTap: onReplyTap,
                  isJoke: isJoke,
                ),
                if (unread) ...<Widget>[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF18C27C),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(String raw) {
    if (raw.isEmpty) {
      return '';
    }

    try {
      final DateTime dt = DateTime.parse(raw).toLocal();
      return '${dt.year.toString().padLeft(4, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}
class _ReplyPillButton extends StatelessWidget {
  const _ReplyPillButton({
    required this.onTap,
    required this.isJoke,
  });

  final VoidCallback onTap;
  final bool isJoke;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = isJoke
        ? const <Color>[Color(0xFF8477FF), Color(0xFFB295FF)]
        : const <Color>[Color(0xFF0FA7B5), Color(0xFF5F8CFF)];

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1F5F8CFF),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.reply_rounded,
                  size: 15,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  isJoke ? 'رد بقفشة' : 'رد بكلمة لطيفة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.unread,
    required this.category,
  });

  final bool unread;
  final String category;

  @override
  Widget build(BuildContext context) {
    final bool isJoke = category.toLowerCase() == 'joke';
    final String categoryText = isJoke ? 'قفشة' : 'رسالة';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: unread
            ? const Color(0xFFE7FBF3)
            : const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        unread ? '$categoryText جديدة' : categoryText,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: unread
              ? const Color(0xFF14915F)
              : (isJoke
              ? const Color(0xFF6F63D9)
              : const Color(0xFF728096)),
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.imageUrl,
    required this.fallbackText,
  });

  final String imageUrl;
  final String fallbackText;

  @override
  Widget build(BuildContext context) {
    final String firstChar =
    fallbackText.trim().isEmpty ? 'U' : fallbackText.trim()[0].toUpperCase();

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFEAF2FF),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isNotEmpty
          ? Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Center(
            child: Text(
              firstChar,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF4267B2),
              ),
            ),
          );
        },
      )
          : Center(
        child: Text(
          firstChar,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF4267B2),
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xEFFFFFFF),
            border: Border.all(
              color: const Color(0xFFE1E9F3),
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 21,
            color: const Color(0xFF55657D),
          ),
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) {
      return const SizedBox(height: 8);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        count,
            (int index) {
          final bool active = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: active
                  ? const Color(0xFF2E78C7)
                  : const Color(0xFFD6DFEA),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 228,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFF7F9FC),
        border: Border.all(color: const Color(0xFFE7EDF5)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 228,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFFFFF8F8),
        border: Border.all(color: const Color(0xFFFFD7D7)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFD9534F),
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF7D3A3A),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

Future<void> showSweetReplyBottomSheet({
  required BuildContext context,
  required String loginUserId,
  required String receiverUserId,
  required String receiverName,
  required String itemId,
  required int relationType,
  String initialCategory = 'sweet',
}) async {
  final SweetMessageProvider provider = SweetMessageProvider(
    repository: SweetMessageRepository(
      baseUrl: PsConfig.ps_app_url,
      headers: <String, String>{
        'Accept': 'application/json',
      },
    ),
  );

  provider.reset();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return ChangeNotifierProvider<SweetMessageProvider>.value(
        value: provider,
        child: _ReplyBottomSheetBody(
          loginUserId: loginUserId,
          receiverUserId: receiverUserId,
          receiverName: receiverName,
          itemId: itemId,
          relationType: relationType,
          initialCategory: initialCategory,
        ),
      );
    },
  );
}

class _ReplyBottomSheetBody extends StatefulWidget {
  const _ReplyBottomSheetBody({
    required this.loginUserId,
    required this.receiverUserId,
    required this.receiverName,
    required this.itemId,
    required this.relationType,
    required this.initialCategory,
  });

  final String loginUserId;
  final String receiverUserId;
  final String receiverName;
  final String itemId;
  final int relationType;
  final String initialCategory;

  @override
  State<_ReplyBottomSheetBody> createState() => _ReplyBottomSheetBodyState();
}

class _ReplyBottomSheetBodyState extends State<_ReplyBottomSheetBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  String get _currentCategory =>
      _tabController.index == 0 ? 'sweet' : 'joke';

  @override
  void initState() {
    super.initState();

    final int initialIndex =
    widget.initialCategory.toLowerCase() == 'joke' ? 1 : 0;

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final SweetMessageProvider provider =
      Provider.of<SweetMessageProvider>(context, listen: false);

      provider.setMessageCategory(_currentCategory);
      await provider.loadPhraseSuggestions(
        loginUserId: widget.loginUserId,
        receiverUserId: widget.receiverUserId,
      );

      if (mounted) {
        setState(() {});
      }
    });

    _tabController.addListener(_onTabChanged);
  }

  Future<void> _onTabChanged() async {
    if (_tabController.indexIsChanging) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {});

    final SweetMessageProvider provider =
    Provider.of<SweetMessageProvider>(context, listen: false);

    if (provider.messageCategory == _currentCategory) {
      return;
    }

    provider.setMessageCategory(_currentCategory);
    await provider.loadPhraseSuggestions(
      loginUserId: widget.loginUserId,
      receiverUserId: widget.receiverUserId,
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SweetMessageProvider provider =
    Provider.of<SweetMessageProvider>(context);

    final bool isJoke = _currentCategory == 'joke';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFEFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewPadding.bottom + 14,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.74,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFD7E3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: isJoke
                          ? const <Color>[
                        Color(0xFFF7F3FF),
                        Colors.white,
                      ]
                          : const <Color>[
                        Color(0xFFF2FAFB),
                        Colors.white,
                      ],
                    ),
                    border: Border.all(
                      color: isJoke
                          ? const Color(0xFFE5DAFF)
                          : const Color(0xFFD7EEF2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isJoke
                            ? const Color(0xFF0B2A58)
                            : const Color(0xFF5F8CFF))
                            .withOpacity(0.10),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isJoke
                                ? const <Color>[
                              Color(0xFF0B2A58),
                              Color(0xFF123F78),
                            ]
                                : const <Color>[
                              Color(0xFF0FA7B5),
                              Color(0xFF5F8CFF),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            isJoke ? '😄' : '✨',
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'ابعت رد لطيف إلى ${widget.receiverName}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A2433),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isJoke
                                  ? 'اختَر قفشة خفيفة ترد بها بشكل لطيف.'
                                  : 'اختَر رسالة جميلة ترسم ابتسامة وتوصل ذوقك.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: const Color(0xFF6B7A90),
                                height: 1.35,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F8FC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2EAF2)),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isJoke
                            ? const <Color>[
                          Color(0xFF0B2A58),
                          Color(0xFF123F78),
                        ]
                            : const <Color>[
                          Color(0xFF0FA7B5),
                          Color(0xFF5F8CFF),
                        ],
                      ),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF46566C),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    tabs: const <Widget>[
                      Tab(text: 'رسائل لطيفة'),
                      Tab(text: 'تعليقات خفيفة'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      _ReplyPhraseTabContent(
                        provider: provider,
                        category: 'sweet',
                      ),
                      _ReplyPhraseTabContent(
                        provider: provider,
                        category: 'joke',
                      ),
                    ],
                  ),
                ),
                if ((provider.errorMessage ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 6),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3F3),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFFD5D5),
                        ),
                      ),
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isJoke
                            ? const <Color>[
                          Color(0xFF0B2A58),
                          Color(0xFF123F78),
                        ]
                            : const <Color>[
                          Color(0xFF0B2A58),
                          Color(0xFF123F78),
                        ],
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x220B2A58),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: provider.isSending
                          ? null
                          : () async {
                        final bool ok =
                        await provider.sendSelectedPhrase(
                          loginUserId: widget.loginUserId,
                          receiverUserId: widget.receiverUserId,
                          itemId: widget.itemId,
                          relationType: widget.relationType,
                        );

                        if (!mounted) {
                          return;
                        }

                        if (ok) {
                          final NavigatorState navigator = Navigator.of(context);
                          final ScaffoldMessengerState messenger =
                          ScaffoldMessenger.of(context);

                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                              content:
                              Text('تم إرسال الرسالة بنجاح ✨'),
                            ),
                          );
                        }
                      },
                      icon: provider.isSending
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.3,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Icon(
                        Icons.send_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        provider.isSending
                            ? 'جارٍ الإرسال...'
                            : (isJoke ? 'إرسال القفشة' : 'إرسال الرسالة'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReplyPhraseTabContent extends StatelessWidget {
  const _ReplyPhraseTabContent({
    required this.provider,
    required this.category,
  });

  final SweetMessageProvider provider;
  final String category;

  @override
  Widget build(BuildContext context) {
    final bool isJoke = category == 'joke';

    if (provider.isLoadingPhrases) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.phrases.isEmpty) {
      return Center(
        child: Text(
          isJoke
              ? 'لا توجد تعليقات خفيفة مناسبة الآن'
              : 'لا توجد رسائل لطيفة مناسبة الآن',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B7A90),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 4),
      itemCount: provider.phrases.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        mainAxisExtent: 126,
      ),
      itemBuilder: (context, index) {
        final SweetPhrase phrase = provider.phrases[index];
        final bool selected =
            provider.selectedPhrase?.phraseId == phrase.phraseId;

        return _ReplyPhraseChoiceCard(
          phrase: phrase,
          selected: selected,
          isJoke: isJoke,
          onTap: () => provider.selectPhrase(phrase),
        );
      },
    );
  }
}

class _ReplyPhraseChoiceCard extends StatelessWidget {
  const _ReplyPhraseChoiceCard({
    required this.phrase,
    required this.selected,
    required this.isJoke,
    required this.onTap,
  });

  final SweetPhrase phrase;
  final bool selected;
  final bool isJoke;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = isJoke
        ? const <Color>[
      Color(0xFF213F96),
      Color(0xFF172F78),
      Color(0xFF0E235F),
    ]
        : const <Color>[
      Color(0xFF061F46),
      Color(0xFF0C587A),
      Color(0xFF24A9C4),
      Color(0xFF29D6C7),
    ];

    return AnimatedScale(
      scale: selected ? 1.0 : 0.985,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.72),
            width: selected ? 2 : 1.35,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: (isJoke ? const Color(0xFF172F78) : const Color(0xFF0C587A))
                  .withOpacity(selected ? 0.34 : 0.18),
              blurRadius: selected ? 22 : 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.78),
                          width: 1.05,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isJoke)
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: Opacity(
                      opacity: 0.20,
                      child: Image.asset(
                        'assets/images/Taapdeel_icon.png',
                        width: 34,
                        height: 34,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                else
                  PositionedDirectional(
                    top: 8,
                    end: 8,
                    child: Icon(
                      Icons.sentiment_very_satisfied_rounded,
                      color: Colors.white.withOpacity(0.22),
                      size: 28,
                    ),
                  ),
                if (selected)
                  PositionedDirectional(
                    top: 9,
                    start: 9,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.92),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: isJoke ? const Color(0xFF213F96) : const Color(0xFF0C587A),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Center(
                      child: Text(
                        phrase.phraseText,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.2,
                          height: 1.55,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
