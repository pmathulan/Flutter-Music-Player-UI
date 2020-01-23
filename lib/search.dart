import 'dart:core' as prefix0;
import 'dart:core';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';

class DataSearch extends SearchDelegate<String> {
  final mainList;

  TextEditingController eMailOrPhoneController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  FocusNode eMailOrPhoneFocusNode = FocusNode();
  FocusNode descriptionFocusNode = FocusNode();
  bool isDescriptionValuable = true;

  DataSearch({
    this.mainList,
  });

  var suggestionList;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
          showSuggestions(context);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView.builder(
      itemCount:
          suggestionList.isEmpty ? mainList.length : suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            suggestionList.isEmpty
                ? mainList[index].name
                : suggestionList[index].name,
            style: TextStyle(color: Colors.grey),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    suggestionList = query.isEmpty
        ? mainList
        : mainList.where((p) {
            var listItemText = p.name.toString().toLowerCase();
            return listItemText.contains(query.toLowerCase());
          }).toList();
    if (suggestionList.length == 0) return emptyResultWidget(context);
    return ListView.builder(
      itemBuilder: (context, index) {
        return ListTile(
          title: RichText(
            text: TextSpan(
                text: suggestionList[index].name.toString().substring(
                    0, suggestionList[index].name.toLowerCase().indexOf(query)),
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    fontSize: 16),
                children: [
                  TextSpan(
                    text: suggestionList[index].name.toString().substring(
                        suggestionList[index].name.toLowerCase().indexOf(query),
                        suggestionList[index]
                                .name
                                .toLowerCase()
                                .indexOf(query) +
                            query.length),
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: suggestionList[index].name.toString().substring(
                        suggestionList[index]
                                .name
                                .toLowerCase()
                                .indexOf(query) +
                            query.length),
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.w500),
                  )
                ]),
          ),
          onTap: () {
            showResults(context);
            close(context, suggestionList[index].id.toString());
          },
        );
      },
      itemCount: suggestionList.length,
    );
  }

  Widget emptyResultWidget(BuildContext context) {
    descriptionController.text = query;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.asset(
              'images/nodata.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Your searching result is empty. you can now request for your favorites radio.',
            textAlign: TextAlign.center,
          ),
        ),
        OutlineButton(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Request'),
          ),
          onPressed: () {
            close(context, null);
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: requestForm(context),
                  );
                });
          },
        ),
      ],
    );
  }

  Widget requestForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
//        crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 36,
            ),
            Padding(
              padding: const EdgeInsets.all(
                16,
              ),
              child: TextFormField(
                  textInputAction: TextInputAction.next,
                  focusNode: eMailOrPhoneFocusNode,
                  controller: eMailOrPhoneController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'E-Mail Address',
                      isDense: true,
                      border: OutlineInputBorder(),
                      helperText: '* Not required field'),
                  onFieldSubmitted: (term) {
                    eMailOrPhoneFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(descriptionFocusNode);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                focusNode: descriptionFocusNode,
                controller: descriptionController,
                maxLines: 3,
                autocorrect: false,
                decoration: InputDecoration(
                    labelText: 'Requesting Radio Name',
                    errorText: isDescriptionValuable
                        ? null
                        : 'Description must be more than 5 character',
                    isDense: true,
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, right: 16, left: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.blueGrey[300],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Send',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      _launchURL(descriptionController.text);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _launchURL(String body) async {
    var url =
        'mailto:p.mathulan@gmail.com?subject=New Radio Request&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
