import 'package:flutter/material.dart';
import 'package:mobile_client/Data_structur/AcessToken.dart';
import 'package:mobile_client/Data_structur/User.dart';
import 'package:mobile_client/Widget/Profil/LinkedAccount/AccountCard.dart';

class Link_Account extends StatefulWidget {
  final AcessToken accessToken;
  final User Userprofile;

  const Link_Account({
    Key? key,
    required this.accessToken,
    required this.Userprofile,
  }) : super(key: key);
  @override
  _Link_AccountState createState() => _Link_AccountState();
}

class _Link_AccountState extends State<Link_Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Linked Account",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(
          color: Colors.white,
        ),
      ),
      body: Container(
        color: Colors.black,
        height: double.infinity,
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
            child: Column(
              children: [
                AccountCard(
                    accessToken: widget.accessToken,
                    accountName: 'Google',
                    linkIsLinked: "/auth/google/link-status",
                    linkUrl: "/auth/google/link",
                    onPressed: () {}),
                AccountCard(
                    accessToken: widget.accessToken,
                    accountName: 'Github',
                    linkIsLinked: "/auth/github/link-status",
                    linkUrl: "/auth/github/link",
                    onPressed: () {}),
                AccountCard(
                    accessToken: widget.accessToken,
                    accountName: 'Discord',
                    linkIsLinked: "/auth/discord/link-status",
                    linkUrl: "/auth/discord/link",
                    onPressed: () {}),
                AccountCard(
                  accessToken: widget.accessToken,
                  accountName: 'Spotify',
                  linkIsLinked: "/auth/spotify/link-status",
                  linkUrl: "/auth/spotify/link",
                  onPressed: () {}
                ),
                AccountCard(
                    accessToken: widget.accessToken,
                    accountName: 'Twitch',
                    linkIsLinked: "/auth/twitch/link-status",
                    linkUrl: "/auth/twitch/link",
                    onPressed: () {}
                  ),
              ],
            )),
      ),
    );
  }
}
