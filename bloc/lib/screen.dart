import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatBloc bloc = ChatBloc();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bloc.startAutoMessage();
    });
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.black12,
        title: const Text(
          'Bloc',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatItem>>(
              initialData: bloc.state,
              stream: bloc.stream,
              builder: (context, snapshot) {
                final List<ChatItem> items = snapshot.data ?? [];
                return ListView.separated(
                  padding: const EdgeInsets.all(20.0),
                  reverse: true,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final ChatItem item = items.reversed.toList()[index];
                    if (item.isMe) {
                      return ChatTile.right(message: item.message);
                    } else {
                      return ChatTile.left(message: item.message);
                    }
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemCount: items.length,
                );
              },
            ),
          ),
          ChatBottomNavigationBar(
            onSend: (message) async {
              final ChatItem item = ChatItem(message: message);
              final ChatEvent event = AddChatEvent(item: item);

              bloc.add(event);
            },
          ),
        ],
      ),
    );
  }
}

abstract class ChatEvent {}

class AddChatEvent extends ChatEvent {
  final ChatItem item;

  AddChatEvent({required this.item});
}

class ChatBloc extends Bloc<ChatEvent, List<ChatItem>> {
  final Stream<int> _stream = Stream<int>.periodic(
    const Duration(seconds: 5),
    (count) => count,
  ).take(5);

  ChatBloc() : super([]) {
    on<AddChatEvent>((event, emit) => emit([...state, event.item]));
  }

  void startAutoMessage() {
    _stream.listen((count) {
      if (count == 5) {
        return;
      }

      final String message;
      if (count == 0) {
        message = '채팅을 시작합니다.';
      } else if (count == 4) {
        message = '채팅을 종료합니다.';
      } else {
        message = 'Hello.' * count;
      }

      final ChatItem item = ChatItem(message: message, isMe: false);
      final AddChatEvent event = AddChatEvent(item: item);

      add(event);
    });
  }
}

class ChatItem {
  final String message;
  final bool isMe;

  ChatItem({required this.message, this.isMe = true});
}

class ChatTile extends StatelessWidget {
  final ChatItem item;

  const ChatTile({super.key, required this.item});

  factory ChatTile.left({required String message}) {
    return ChatTile(item: ChatItem(message: message, isMe: false));
  }

  factory ChatTile.right({required String message}) {
    return ChatTile(item: ChatItem(message: message, isMe: true));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: item.isMe
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (item.isMe) ...[const SizedBox(width: 60)],
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(item.isMe ? 18 : 4),
                bottomRight: Radius.circular(item.isMe ? 4 : 18),
              ),
              color: item.isMe ? const Color(0xFF007AFF) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 16.0,
              ),
              child: Text(
                item.message,
                style: TextStyle(
                  color: item.isMe ? Colors.white : Colors.black87,
                  fontSize: 15.0,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
        if (!item.isMe) ...[const SizedBox(width: 60)],
      ],
    );
  }
}

class ChatBottomNavigationBar extends StatefulWidget {
  final Function(String) onSend;

  const ChatBottomNavigationBar({super.key, required this.onSend});

  @override
  State<ChatBottomNavigationBar> createState() =>
      _ChatBottomNavigationBarState();
}

class _ChatBottomNavigationBarState extends State<ChatBottomNavigationBar> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              MediaQuery.of(context).viewPadding.bottom +
              8,
          top: 12,
          left: 16,
          right: 16,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[200]!, width: 1),
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 20.0,
                    ),
                    border: InputBorder.none,
                    hintText: '메시지를 입력하세요...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () {
                    final String message = controller.text.trim();
                    if (message.isNotEmpty) {
                      widget.onSend.call(message);
                      controller.clear();
                    }
                  },
                  child: const Center(
                    child: Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
