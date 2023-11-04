import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:select_dialog/select_dialog.dart';

import '../../helper/dimensions.dart';
import '../../helper/assets.dart';
import '../../helper/styles.dart';
import '../../models/nearby_driver.dart';

class DriverListWidget extends StatelessWidget {
  final NearbyDriver? selectedDriver;
  final List<NearbyDriver> drivers;
  final Function? onDriverSelected;
  const DriverListWidget(
      this.selectedDriver, this.drivers, this.onDriverSelected,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        SelectDialog.showModal<NearbyDriver>(
          context,
          label: AppLocalizations.of(context)!.changeDriver,
          selectedValue: selectedDriver,
          items: drivers,
          showSearchBox: drivers.length > 5,
          onChange: (NearbyDriver selected) async {
            if (onDriverSelected != null) onDriverSelected!(selected);
          },
          itemBuilder:
              (BuildContext context, NearbyDriver item, bool isSelected) {
            return Container(
              decoration: !isSelected
                  ? null
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Theme.of(context).highlightColor,
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
              child: ListTile(
                leading: CircleAvatar(
                  child: item.avatar == null || item.avatar!.isEmpty
                      ? Image.asset(
                          Assets.placeholderUser,
                          color: Theme.of(context).highlightColor,
                        )
                      : null,
                  backgroundImage: item.avatar == null || item.avatar!.isEmpty
                      ? null
                      : NetworkImage(item.avatar!),
                ),
                selected: isSelected,
                title: Text(
                  item.name,
                  style: khulaBold.copyWith(
                      color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            );
          },
        );
      },
      child: Card(
        elevation: 8,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(top: 5),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFFD1D5DA), width: 2)),
                    child: ClipOval(
                      child: selectedDriver?.avatar != null &&
                              selectedDriver!.avatar!.isNotEmpty
                          ? CachedNetworkImage(
                              progressIndicatorBuilder:
                                  (context, url, progress) => Center(
                                child: CircularProgressIndicator(
                                  value: progress.progress,
                                ),
                              ),
                              imageUrl: selectedDriver!.avatar!,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              Assets.placeholderUser,
                              color: Theme.of(context).primaryColor,
                              height: 70,
                              width: 70,
                              fit: BoxFit.scaleDown,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: Dimensions.PADDING_SIZE_DEFAULT,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDriver!.name,
                          style: khulaBold.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    5,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                  vertical: 3, horizontal: 8),
                              child: Text(
                                selectedDriver!.ridesCount,
                                style: khulaSemiBold.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            if (selectedDriver!.distance != null)
                              Expanded(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .fromPickupLocation(
                                    selectedDriver!.distance!,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          AppLocalizations.of(context)!
                              .driverDetailsDisplayedRidePanel,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                AppLocalizations.of(context)!.changeDriver,
                textAlign: TextAlign.end,
                style: khulaSemiBold.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
