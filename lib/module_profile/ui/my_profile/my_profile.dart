import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inject/inject.dart';
import 'package:swaptime_flutter/camera/camer_routes.dart';
import 'package:swaptime_flutter/generated/l10n.dart';
import 'package:swaptime_flutter/module_home/home.routes.dart';
import 'package:swaptime_flutter/module_profile/profile_routes.dart';
import 'package:swaptime_flutter/module_profile/state/my_profile_state.dart';
import 'package:swaptime_flutter/module_profile/state_manager/my_profile/my_profile_state_manager.dart';
import 'package:swaptime_flutter/module_theme/service/theme_service/theme_service.dart';
import 'package:swaptime_flutter/utils/app_bar/swaptime_app_bar.dart';

@provide
class MyProfileScreen extends StatefulWidget {
  final MyProfileStateManager _stateManager;

  MyProfileScreen(this._stateManager);

  @override
  State<StatefulWidget> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  String imageUrl;
  String imageLocation;
  bool uploading = false;
  bool submittingProfile = false;

  MyProfileState currentState;

  @override
  void initState() {
    super.initState();
    widget._stateManager.stateStream.listen((event) {
      currentState = event;
      uploading = false;
      submittingProfile = false;
      processEvent();
    });
  }

  void processEvent() {
    if (currentState is MyProfileStateImageUploadSuccess) {
      MyProfileStateImageUploadSuccess state = currentState;
      imageUrl = state.imageUrl;
      setState(() {});
    }
    if (currentState is MyProfileStateUpdateSuccess) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        HomeRoutes.ROUTE_HOME,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    imageLocation = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      appBar: SwaptimeAppBar.getBackEnabledAppBar(),
      body: getUI(),
    );
  }

  Widget getUI() {
    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        getUserImage(),
        Flex(
          direction: Axis.vertical,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'My Name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                minLines: 3,
                maxLines: 5,
                controller: _aboutController,
                decoration: InputDecoration(labelText: 'About Me'),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            saveProfile();
          },
          child: Container(
            decoration: BoxDecoration(color: SwapThemeDataService.getAccent()),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    !submittingProfile
                        ? S.of(context).saveProfile
                        : S.of(context).saving,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget getUserImage() {
    if (imageUrl != null) {
      return MediaQuery.of(context).viewInsets.bottom == 0
          ? Container(
              height: 256,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Positioned.fill(
                      child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  )),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          CameraRoutes.ROUTE_CAMERA,
                          arguments: ProfileRoutes.MY_ROUTE_PROFILE,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: SwapThemeDataService.getPrimary(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          : Container();
    } else if (imageLocation != null) {
      return MediaQuery.of(context).viewInsets.bottom == 0
          ? Container(
              height: 256,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.file(
                      File(imageLocation),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 16,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          CameraRoutes.ROUTE_CAMERA,
                          arguments: ProfileRoutes.MY_ROUTE_PROFILE,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: SwapThemeDataService.getPrimary(),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                      child: Container(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                          color: SwapThemeDataService.getPrimary(),
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: GestureDetector(
                        onTap: () {
                          uploading = true;
                          setState(() {});
                          widget._stateManager.upload(imageLocation);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            uploading != true ? 'Upload Me!' : 'Uploading',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            )
          : Container();
    }
    return MediaQuery.of(context).viewInsets.bottom == 0
        ? Container(
            height: 256,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Positioned.fill(
                    child: Container(
                        height: 256,
                        width: double.infinity,
                        child: SvgPicture.asset(
                          'assets/images/logo.svg',
                          fit: BoxFit.cover,
                        ))),
                Positioned.fill(
                    child: Container(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      color: SwapThemeDataService.getPrimary(),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          CameraRoutes.ROUTE_CAMERA,
                          arguments: ProfileRoutes.MY_ROUTE_PROFILE,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Add Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          )
        : Container();
  }

  void saveProfile() {
    if (_aboutController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: S.of(context).pleaseProvideAShortStoryAboutYou);
      return;
    }
    if (_nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: S.of(context).pleaseProvideYourName);
      return;
    }
    if (imageUrl == null) {
      Fluttertoast.showToast(msg: S.of(context).pleaseUploadYourImage);
      return;
    }
    submittingProfile = true;
    setState(() {});
    widget._stateManager.setMyProfile(
      _nameController.text.trim(),
      _aboutController.text.trim(),
      imageUrl,
    );
  }
}
