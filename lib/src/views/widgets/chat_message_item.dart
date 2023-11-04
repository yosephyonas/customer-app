import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:bubble/bubble.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/styles.dart';
import '../../models/message.dart';
import '../../repositories/user_repository.dart';

class ChatMessageItem extends StatelessWidget {
  final Message message;
  final bool showNip;

  ChatMessageItem(this.message, {this.showNip = true});

  @override
  Widget build(BuildContext context) {
    return currentUser.value.id == this.message.sender.id
        ? getSentMessageLayout(context)
        : getReceivedMessageLayout(context);
  }

  Widget getSentMessageLayout(context) {
    final bool lightMode = Theme.of(context).brightness == Brightness.light;
    return Bubble(
      margin: BubbleEdges.only(
          top: showNip ? 5 : 0, bottom: 5, right: showNip ? 0 : 8),
      alignment: Alignment.topRight,
      nip: showNip ? BubbleNip.rightTop : BubbleNip.no,
      elevation: 5,
      color: lightMode
          ? Color.fromRGBO(225, 255, 199, 1.0)
          : Theme.of(context).primaryColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        SizedBox(height: 5),
        if (message.message != null && message.message!.isNotEmpty)
          Text(message.message ?? '',
              softWrap: true,
              style: lightMode
                  ? khulaBold
                  : khulaBold
                      .merge(TextStyle(color: Colors.black, fontSize: 14))),
        message.media != null
            ? message.media!.mimeType == 'application/pdf'
                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    padding: EdgeInsets.all(8),
                    child: InkWell(
                      onTap: () async {
                        await launchUrl(Uri.parse(message.media!.url));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 5),
                          Icon(
                            Icons.attach_file,
                            color: Theme.of(context).highlightColor,
                          ),
                          SizedBox(width: 5),
                          Text(
                            message.media!.fileName,
                            style: khulaBold.copyWith(
                              color: Theme.of(context).highlightColor,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: new BoxConstraints(
                      maxHeight: 300,
                    ),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: message.media!.url,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ))
            : SizedBox(),
        SizedBox(height: 5),
        Text(
          DateFormat('dd/MM/yyyy HH:mm').format(message.createdAt),
          style: Theme.of(context).textTheme.button!.merge(lightMode
              ? TextStyle(fontSize: 12)
              : TextStyle(fontSize: 12, color: Colors.black)),
        ),
      ]),
    );
  }

  Widget getReceivedMessageLayout(context) {
    return Bubble(
      margin: BubbleEdges.only(
          top: showNip ? 5 : 0, bottom: 5, left: showNip ? 0 : 8),
      alignment: Alignment.topLeft,
      nip: showNip ? BubbleNip.leftTop : BubbleNip.no,
      elevation: 5,
      color: Theme.of(context).cardColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(message.sender.name,
            softWrap: true, style: Theme.of(context).textTheme.subtitle2),
        SizedBox(height: 5),
        if (message.message != null && message.message!.isNotEmpty)
          Text(message.message!,
              softWrap: true, style: Theme.of(context).textTheme.bodyText2),
        message.media != null
            ? message.media!.mimeType == 'application/pdf'
                ? Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    padding: EdgeInsets.all(8),
                    child: InkWell(
                      onTap: () async {
                        await launchUrl(Uri.parse(message.media!.url));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 5),
                          Icon(
                            Icons.attach_file,
                            color: Theme.of(context).highlightColor,
                          ),
                          SizedBox(width: 5),
                          Text(
                            message.media!.fileName,
                            style: khulaBold.copyWith(
                              color: Theme.of(context).highlightColor,
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: new BoxConstraints(
                      maxHeight: 300,
                    ),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: message.media!.url,
                      placeholder: (context, url) => Image.asset(
                        'assets/img/loading.gif',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ))
            : SizedBox(),
        SizedBox(height: 5),
        Text(
          DateFormat('dd/MM/yyyy HH:mm').format(message.createdAt),
          style: Theme.of(context)
              .textTheme
              .button!
              .merge(TextStyle(fontSize: 12)),
        ),
      ]),
    );
  }
}
