import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:drighna_ed_tech/provider/about_School_provider.dart';

class AboutSchool extends ConsumerStatefulWidget {
  const AboutSchool({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutSchool> {
  @override
  void initState() {
    super.initState();
    ref.read(aboutSchoolProvider.notifier).fetchAboutSchoolData();
  }

  @override
  Widget build(BuildContext context) {
    final aboutSchoolData = ref.watch(aboutSchoolProvider);

    // Handle the UI rendering based on the state of aboutSchoolData
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title:
            const Text('About School', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: aboutSchoolData == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show a loading indicator while data is null
          : SingleChildScrollView(
              // Once data is not null, render your UI
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (aboutSchoolData.imageUrl.isNotEmpty)
                    Center(
                      child: CachedNetworkImage(
                        imageUrl: aboutSchoolData.imageUrl,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  ListTile(
                    title: const Text('Name'),
                    trailing: Text(
                      aboutSchoolData.name,
                      style: const TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Address'),
                    trailing: Text(
                      aboutSchoolData.address,
                      style: const TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Phone'),
                    trailing: Text(
                      aboutSchoolData.phone,
                      style: const TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Email'),
                    trailing: Text(
                      aboutSchoolData.email,
                      style: const TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('School Code'),
                    trailing: Text(
                      aboutSchoolData.schoolCode,
                      style: const TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Current Session'),
                    trailing: Text(
                      aboutSchoolData.currentSession,
                      style: const TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Session Start Month'),
                    trailing: Text(
                      aboutSchoolData.sessionStartMonth,
                      style: const TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                  ),
                  // Add more ListTiles for additional information as needed
                ],
              ),
            ),
    );
  }
}
