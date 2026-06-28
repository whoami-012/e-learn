import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/user_provider.dart';
import '../controllers/live_class_controller.dart';
import 'create_live_class_screen.dart';
import 'live_class_detail_screen.dart';

class LiveClassListScreen extends StatefulWidget {
  const LiveClassListScreen({super.key});
  @override
  State<LiveClassListScreen> createState() => _LiveClassListScreenState();
}

class _LiveClassListScreenState extends State<LiveClassListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<LiveClassController>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LiveClassController>();
    final faculty = context.watch<UserProvider>().isFaculty;
    Widget body;
    if (state.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.error != null) {
      body = ListView(children: [
        Padding(padding: const EdgeInsets.all(24), child: Text(state.error!))
      ]);
    } else if (state.classes.isEmpty) {
      body = ListView(children: const [
        Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: Text('No live classes available.')))
      ]);
    } else {
      body = ListView.builder(
        itemCount: state.classes.length,
        itemBuilder: (_, index) {
          final item = state.classes[index];
          final date = MaterialLocalizations.of(context)
              .formatFullDate(item.scheduledStartTime);
          final time =
              TimeOfDay.fromDateTime(item.scheduledStartTime).format(context);
          return Card(
            child: ListTile(
              leading: Icon(item.status == 'live'
                  ? Icons.wifi_tethering
                  : Icons.video_camera_front),
              title: Text(item.title),
              subtitle: Text('${item.facultyName ?? 'Faculty'}\n$date  $time'),
              isThreeLine: true,
              trailing: Chip(label: Text(item.status)),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LiveClassDetailScreen(liveClass: item))),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Live classes')),
      floatingActionButton: faculty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CreateLiveClassScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Schedule'),
            )
          : null,
      body: RefreshIndicator(onRefresh: state.load, child: body),
    );
  }
}
