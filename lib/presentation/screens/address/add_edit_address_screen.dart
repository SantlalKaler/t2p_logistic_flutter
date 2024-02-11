import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:t2p_logistic/domain/Model/user/AddressListResponse.dart'
    as addres;
import 'package:t2p_logistic/presentation/theme/resource/dimens.dart';
import 'package:t2p_logistic/presentation/widgets/app_scaffold.dart';

import '../../../domain/enums/add_edit_delivery_boy.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/circular_loadings.dart';
import '../../widgets/custom_snackbar.dart';
import 'address_controller.dart';
import 'location_from_map.dart';
import 'map_location_controller.dart';

class AddEditAddress extends StatefulWidget {
  final addres.Address? address;
  final bool isEdit;
  final bool redirectToHome;

  const AddEditAddress(
      {super.key,
      required this.isEdit,
      required this.redirectToHome,
      this.address});

  @override
  AddEditAddressState createState() => AddEditAddressState();
}

class AddEditAddressState extends State<AddEditAddress> {
  final _formKey = GlobalKey<FormState>();
  bool isDefault = true;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _addressController2 = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  @override
  void initState() {
    AddressController addressController = Get.find();
    addressController.getAllStates();
    if (widget.isEdit == true) {
      addressController.selectedAddressType.value =
          widget.address!.title.toString().toLowerCase() ==
                  AddressType.work.name
              ? AddressType.work
              : widget.address!.title.toString().toLowerCase() ==
                      AddressType.home.name
                  ? AddressType.home
                  : AddressType.other;

      _fullNameController.text = widget.address!.contactName ?? '';
      _mobileNoController.text = widget.address!.contactMobile ?? '';
      _addressController.text = widget.address!.address ?? '';
      _addressController2.text = widget.address!.address2 ?? '';
      _landmarkController.text = widget.address!.landmark ?? '';

      _countryController.text = 'India';

      _stateController.text = widget.address!.state!.name ?? "";

       addressController.getAllCityByStatess(widget.address!.state!.id);
      _cityController.text = widget.address!.city!.name ?? "";

       addressController.getZipCodeByCity(widget.address!.city!.id);
      _postalCodeController.text = widget.address!.pincode ?? '';

      addressController.lat.value =
          widget.address!.position!.coordinates?[0] ?? 0.0;
      addressController.lng.value =
          widget.address!.position!.coordinates?[1] ?? 0.0;
    } else {
      addressController.selectedAddressType.value = AddressType.home;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AddressController addressController = Get.find();
    addressController.isLocationOnMapSelected.value = false;
    MapLocationController mapLocationController = Get.find();

    return Obx(() => AppScaffold(
        appBar: appBar(
          title: "Add Address",
        ), body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(DimensConstants.screePadding),
            child: Form(
              key: _formKey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      style: Theme.of(context).textTheme.titleSmall,
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        label: Text(
                          'Full name',
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: Theme.of(context).textTheme.titleSmall,
                      controller: _mobileNoController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 10,
                      decoration: const InputDecoration(
                        prefixIcon: Text('    +91 -    '),
                        prefixIconConstraints: BoxConstraints(),
                        counterText: '',
                        label: Text(
                          'Phone number',
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your mobile number';
                        }
                        if (value.length != 10) {
                          return 'Please enter valid mobile number';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: Theme.of(context).textTheme.titleSmall,
                      controller: _addressController,
                      decoration: const InputDecoration(
                          label: Text(
                            'House no./Building name etc.',
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: Theme.of(context).textTheme.titleSmall,
                      controller: _addressController2,
                      decoration: const InputDecoration(
                          label: Text(
                            'Road/Area/Colony',
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: Theme.of(context).textTheme.titleSmall,
                      controller: _landmarkController,
                      decoration: const InputDecoration(
                          label: Text(
                            'Landmark (optional)',
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto),
                    ),
                    const SizedBox(height: 16),
                    DropdownMenu(
                        expandedInsets: const EdgeInsets.all(0),
                        controller: _countryController,
                        hintText: 'Select Country',
                        inputDecorationTheme:
                        Theme.of(context).inputDecorationTheme,
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                            value: 'India',
                            label: 'India',
                          )
                        ],
                        onSelected: (v) {
                          _stateController.clear();
                          _cityController.clear();
                          _postalCodeController.clear();
                        }),
                    const SizedBox(height: 16),
                    DropdownMenu(
                      expandedInsets: const EdgeInsets.all(0),
                      controller: _stateController,
                      hintText: 'Select state',
                      onSelected: (stateId) {
                        _cityController.clear();
                        _postalCodeController.clear();
                        addressController.getAllCityByStatess(stateId);
                      },
                      inputDecorationTheme:
                      Theme.of(context).inputDecorationTheme,
                      dropdownMenuEntries: [
                        for (var item in addressController.stateList)
                          DropdownMenuEntry(value: item.id, label: item.name!)
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownMenu(
                      expandedInsets: const EdgeInsets.all(0),
                      controller: _cityController,
                      enabled: addressController.isLoadingCityByStates.isFalse,
                      hintText: addressController.isLoadingCityByStates.isTrue
                          ? 'Loading cities...'
                          : 'Select city',
                      onSelected: (cityId) {
                        _postalCodeController.clear();
                        addressController.getZipCodeByCity(cityId);
                        mapLocationController
                            .getCordinatesFromAddress(_cityController.text);
                      },
                      inputDecorationTheme:
                      Theme.of(context).inputDecorationTheme,
                      dropdownMenuEntries: [
                        for (var item in addressController.cityList)
                          DropdownMenuEntry(value: item.id, label: item.name!)
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownMenu(
                      expandedInsets: const EdgeInsets.all(0),
                      enabled: addressController.isLoadingZipCodeByCity.isFalse,
                      controller: _postalCodeController,
                      hintText: addressController.isLoadingZipCodeByCity.isTrue
                          ? 'Loading postal codes...'
                          : 'Select postal code',
                      onSelected: (postalCodeId) {},
                      inputDecorationTheme:
                      Theme.of(context).inputDecorationTheme,
                      dropdownMenuEntries: [
                        for (var item in addressController.zipList)
                          DropdownMenuEntry(value: item.id, label: item.name!)
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(
                          () => Wrap(
                        spacing: 5.0,
                        children: List<Widget>.generate(
                          addressController.addressTypes.length,
                              (int index) {
                            bool isSelected =
                                addressController.selectedAddressType.value ==
                                    addressController.addressTypes[index];
                            return ChoiceChip(
                              labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.grey.shade50
                                      : Colors.black87),
                              label: Text(addressController
                                  .addressTypes[index].name
                                  .toUpperCase()),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                addressController.selectedAddressType.value =
                                addressController.addressTypes[index];
                              },
                            );
                          },
                        ).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Obx(
                            () => ElevatedButton(
                            onPressed: addressController
                                  .isAddingEdittingAddress
                                  .isTrue ||
                                  mapLocationController
                                      .isLoading.isTrue
                                  ? null
                                  : () {
                              if (_formKey.currentState!.validate()) {
                                if (addressController
                                    .isLocationOnMapSelected.isTrue) {
                                  _saveAddress();
                                } else {
                                  _selectLocation();
                                }
                              }
                            },
                            child:  addressController
                                  .isAddingEdittingAddress
                                  .isTrue
                                  ? circularloadingWhiteSmall()
                                  : Text(
                              addressController.isLocationOnMapSelected.isTrue
                                  ? 'Save address'
                                  : 'Select location',
                            )),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),
            ),
          ),
        )));
  }

  void _selectLocation() async {
    AddressController addressController = Get.find();
    bool result = await Get.to(const LocationFromMap());
    if (result) {
      addressController.isLocationOnMapSelected.value = true;
    }
  }

  _saveAddress() async {
    AddressController addressController = Get.find();
    if (_countryController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _postalCodeController.text.isEmpty ||
        _stateController.text.isEmpty) {
      CustomSnackBar.showSnackBar(
          CustomSnackBar.error, 'All fields required', CustomSnackBar.error);
    } else {
      String cityId = addressController.cityList
          .firstWhere((p0) => p0.name! == _cityController.text)
          .id!;
      String stateId = addressController.stateList
          .firstWhere((p0) => p0.name! == _stateController.text)
          .id!;
      if (widget.isEdit == false) {
        await addressController.addAddress(
            title: addressController.selectedAddressType.value.name,
            address: _addressController.text,
            address2: _addressController2.text,
            cityId: cityId,
            cityName: _cityController.text,
            stateId: stateId,
            stateName: _stateController.text,
            postOffice: 'not_defined',
            postalCode: _postalCodeController.text,
            contactName: _fullNameController.text,
            contactPhone: _mobileNoController.text,
            lat: addressController.lat.value.toString(),
            lng: addressController.lng.value.toString(),
            landmark: _landmarkController.text,
            redirectToHome: widget.redirectToHome);
      }
      else {
        await addressController.editAddress(
            addressId: widget.address!.id,
            title: addressController.selectedAddressType.value.name,
            address: _addressController.text,
            address2: _addressController2.text,
            cityId: cityId,
            cityName: _cityController.text,
            stateId: stateId,
            stateName: _stateController.text,
            postOffice: 'not_defined',
            postalCode: _postalCodeController.text,
            contactName: _fullNameController.text,
            contactPhone: _mobileNoController.text,
            lat: addressController.lat.value.toString(),
            lng: addressController.lng.value.toString(),
            landmark: _landmarkController.text,
            redirectToHome: widget.redirectToHome);
      }
    }
  }
}
