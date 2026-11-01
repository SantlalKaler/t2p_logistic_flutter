import 'package:flutter/material.dart';

Widget titleDividerSmall(BuildContext context, String title) {
  return Row(
    children: [
      Expanded(child: Divider(color: const Color(0xFFE4E7EC))),
      const SizedBox(width: 12),
      Text(
        title,
        style: Theme.of(context).textTheme.titleMedium!
            .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      const SizedBox(width: 12),
      Expanded(child: Divider(color: const Color(0xFFE4E7EC))),
    ],
  );
}

Widget titleDividerMedium(BuildContext context, String title) {
  return Row(
    children: [
      Expanded(child: Divider(color: const Color(0xFFE4E7EC))),
      const SizedBox(width: 12),
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(width: 12),
      Expanded(child: Divider(color: const Color(0xFFE4E7EC))),
    ],
  );
}

Widget titleDividerUppercase(
  BuildContext context,
  String title,
  bool isInverted,
) {
  return Row(
    children: [
      Expanded(
        child: Divider(
          color: isInverted ? Colors.white : const Color(0xFFE4E7EC),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        title.toUpperCase(),
        style: isInverted
            ? Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade50,
              )
            : Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
              ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Divider(
          color: isInverted ? Colors.white : const Color(0xFFE4E7EC),
        ),
      ),
    ],
  );
}

Widget titleDividerUppercaseRed(
  BuildContext context,
  String title,
  bool isInverted,
) {
  return Row(
    children: [
      Expanded(
        child: Divider(
          color: isInverted ? Colors.white : Theme.of(context).primaryColor,
        ),
      ),
      const SizedBox(width: 12),
      Text(
        title.toUpperCase(),
        style: isInverted
            ? Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade50,
              )
            : Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: FontWeight.w800,
              ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Divider(
          color: isInverted ? Colors.white : Theme.of(context).primaryColor,
        ),
      ),
    ],
  );
}

Widget homeTitleBg(BuildContext context, String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).primaryColorDark,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
        color: Colors.blueGrey.shade50,
        fontSize: 12,
        letterSpacing: 1,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
