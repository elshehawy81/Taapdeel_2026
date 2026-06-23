import 'dart:async';

import 'package:taapdeel/api/common/ps_resource.dart';
import 'package:taapdeel/api/common/ps_status.dart';
import 'package:taapdeel/provider/common/ps_provider.dart';
import 'package:taapdeel/repository/about_us_repository.dart';
import 'package:taapdeel/utils/utils.dart';
import 'package:taapdeel/viewobject/about_us.dart';
import 'package:taapdeel/viewobject/common/ps_value_holder.dart';

class AboutUsProvider extends PsProvider {
  AboutUsProvider(
      {required AboutUsRepository? repo,
      required this.psValueHolder,
      int limit = 0})
      : super(repo, limit) {
    _repo = repo;

    print('about us Provider: $hashCode');

    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
    });
    aboutUsListStream = StreamController<PsResource<List<AboutUs>>>.broadcast();
    subscription =
        aboutUsListStream.stream.listen((PsResource<List<AboutUs>> resource) {
      updateOffset(resource.data!.length);

      _aboutUsList = resource;

      if (resource.status != PsStatus.BLOCK_LOADING &&
          resource.status != PsStatus.PROGRESS_LOADING) {
        isLoading = false;
      }

      if (!isDispose) {
        notifyListeners();
      }
    });
  }

  AboutUsRepository? _repo;
  PsValueHolder? psValueHolder;
  PsResource<List<AboutUs>> _aboutUsList =
      PsResource<List<AboutUs>>(PsStatus.NOACTION, '', <AboutUs>[]);

  PsResource<List<AboutUs>> get aboutUsList => _aboutUsList;
  late StreamSubscription<PsResource<List<AboutUs>>> subscription;
  late StreamController<PsResource<List<AboutUs>>> aboutUsListStream;
  @override
  void dispose() {
    subscription.cancel();
    isDispose = true;
    print('AboutUs Provider Dispose: $hashCode');
    super.dispose();
  }

  Future<dynamic> loadAboutUsList() async {
    isLoading = true;

    isConnectedToInternet = await Utils.checkInternetConnectivity();
    await _repo!.getAllAboutUsList(
        aboutUsListStream, isConnectedToInternet, PsStatus.PROGRESS_LOADING);
  }

  Future<dynamic> nextAboutUsList() async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();

    if (!isLoading && !isReachMaxData) {
      super.isLoading = true;
      await _repo!.getNextPageAboutUsList(
          aboutUsListStream, isConnectedToInternet, PsStatus.PROGRESS_LOADING);
    }
  }

  Future<void> resetAboutUsList() async {
    isConnectedToInternet = await Utils.checkInternetConnectivity();
    isLoading = true;

    updateOffset(0);

    await _repo!.getAllAboutUsList(
        aboutUsListStream, isConnectedToInternet, PsStatus.PROGRESS_LOADING);

    isLoading = false;
  }
}
