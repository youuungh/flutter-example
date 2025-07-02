import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'model/open_ai_model.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ChatGPTApp());
}

class AppConstants {
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? 'YOUR_API_KEY_HERE';
  static const String apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration typingDuration = Duration(milliseconds: 1200);
  static const Duration welcomeAnimationDuration = Duration(milliseconds: 2000);

  static const double borderRadius = 20.0;
  static const double messagePadding = 16.0;
  static const double avatarRadius = 22.0;
  static const double inputHeight = 56.0;
}

class ChatGPTApp extends StatefulWidget {
  const ChatGPTApp({super.key});

  @override
  State<ChatGPTApp> createState() => _ChatGPTAppState();
}

class _ChatGPTAppState extends State<ChatGPTApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1976D2),
        brightness: Brightness.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT',
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: _themeMode,
      home: ChatScreen(onToggleTheme: _toggleTheme, themeMode: _themeMode),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const ChatScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final http.Client _httpClient = http.Client();

  final List<Message> _messages = [];
  bool _isLoading = false;

  late AnimationController _welcomeAnimationController;
  late AnimationController _typingAnimationController;
  late AnimationController _sendButtonController;
  late Animation<double> _welcomeScaleAnimation;
  late Animation<double> _typingAnimation;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _addSystemMessage();
  }

  void _setupAnimations() {
    _welcomeAnimationController = AnimationController(
      duration: AppConstants.welcomeAnimationDuration,
      vsync: this,
    );

    _welcomeScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _welcomeAnimationController,
      curve: Curves.elasticOut,
    ));

    _typingAnimationController = AnimationController(
      duration: AppConstants.typingDuration,
      vsync: this,
    );

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_typingAnimationController);

    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _sendButtonAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.easeInOut,
    ));

    _welcomeAnimationController.forward();
    _typingAnimationController.repeat(reverse: true);
  }

  void _addSystemMessage() {
    _messages.add(Message.system("You are a helpful assistant."));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _welcomeAnimationController.dispose();
    _typingAnimationController.dispose();
    _sendButtonController.dispose();
    _httpClient.close();
    super.dispose();
  }

  void _unfocusTextField() {
    if (_messageFocusNode.hasFocus) {
      _messageFocusNode.unfocus();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppConstants.animationDuration,
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    if (AppConstants.apiKey == 'YOUR_API_KEY_HERE' || AppConstants.apiKey.isEmpty) {
      _showErrorSnackBar('API 키를 설정해주세요.');
      return;
    }

    _sendButtonController.forward().then((_) {
      _sendButtonController.reverse();
    });

    HapticFeedback.lightImpact();

    final userMessage = Message.user(text);
    _messageController.clear();

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final assistantMessage = Message.assistant('');
      setState(() {
        _messages.add(assistantMessage);
      });

      String fullResponse = '';
      await for (final chunk in _sendMessageStream()) {
        fullResponse += chunk;
        setState(() {
          _messages.last = _messages.last.copyWith(content: fullResponse);
        });
        _scrollToBottom();
      }

      if (fullResponse.isEmpty) {
        setState(() {
          _messages.last = _messages.last.copyWith(
            content: '응답을 생성할 수 없었습니다.',
          );
        });
      }
    } catch (e) {
      _handleError(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Stream<String> _sendMessageStream() async* {
    try {
      final request = ChatRequest.gpt35(
        messages: _messages,
        stream: true,
        maxTokens: 1000,
        temperature: 0.7,
      );

      final httpRequest = http.Request('POST', Uri.parse(AppConstants.apiUrl))
        ..headers.addAll({
          'Authorization': 'Bearer ${AppConstants.apiKey}',
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
        })
        ..body = jsonEncode(request.toJson());

      final response = await _httpClient.send(httpRequest);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();

            if (data == '[DONE]') return;

            if (data.isNotEmpty) {
              try {
                final json = jsonDecode(data);
                final content = json['choices']?[0]?['delta']?['content'];
                if (content != null) {
                  yield content as String;
                }
              } catch (e) {
                continue;
              }
            }
          }
        }
      }
    } catch (e) {
      throw Exception('스트리밍 오류: ${e.toString()}');
    }
  }

  void _handleError(dynamic error) {
    String errorMessage = '오류가 발생했습니다: ${error.toString()}';

    setState(() {
      if (_messages.isNotEmpty && _messages.last.content.isEmpty) {
        _messages.last = _messages.last.copyWith(content: errorMessage);
      } else {
        _messages.add(Message.assistant(errorMessage));
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 100,
          left: 16,
          right: 16,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showBottomSheet() {
    _unfocusTextField();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => _buildBottomSheet(),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          _buildBottomSheetItem(
            icon: Icons.refresh_rounded,
            title: '새 채팅',
            subtitle: '현재 대화를 지우고 새로 시작',
            onTap: () {
              Navigator.pop(context);
              _clearChat();
            },
          ),
          _buildBottomSheetItem(
            icon: Icons.copy_rounded,
            title: '대화 복사',
            subtitle: '현재 대화 내용을 클립보드에 복사',
            onTap: () {
              Navigator.pop(context);
              _copyConversation();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomSheetItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('새로운 대화'),
        content: const Text('현재 대화를 삭제하고 새로 시작하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _addSystemMessage();
              });
              HapticFeedback.mediumImpact();
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _copyConversation() {
    final conversation = _displayMessages
        .map((msg) => '${msg.role == 'user' ? '나' : 'AI'}: ${msg.content}')
        .join('\n\n');

    Clipboard.setData(ClipboardData(text: conversation));
    _showErrorSnackBar('대화 내용이 복사되었습니다.');
  }

  List<Message> get _displayMessages {
    return _messages.where((msg) => msg.role != 'system').toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _unfocusTextField,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          leading: IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(
              widget.themeMode == ThemeMode.light
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          title: Text(
            'ChatGPT',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          scrolledUnderElevation: 1,
          actions: [
            IconButton(
              onPressed: _showBottomSheet,
              icon: const Icon(Icons.more_vert_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: _displayMessages.isEmpty
                  ? _buildWelcomeScreen()
                  : _buildChatList(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: AnimatedBuilder(
          animation: _welcomeScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _welcomeScaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'ChatGPT',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI와 대화를 시작해보세요',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '궁금한 것이 있으면 언제든 물어보세요',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _displayMessages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _displayMessages.length) {
          return _buildTypingIndicator();
        }

        final message = _displayMessages[index];
        return _buildMessageBubble(message, index);
      },
    );
  }

  Widget _buildMessageBubble(Message message, int index) {
    final isUser = message.role == 'user';
    final isError = message.content.contains('오류');

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!isUser) ...[
                    _buildAvatar(isError),
                    const SizedBox(width: 12),
                  ],
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.messagePadding),
                      decoration: BoxDecoration(
                        color: _getMessageColor(isUser, isError),
                        borderRadius: _getMessageBorderRadius(isUser),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          color: _getTextColor(isUser, isError),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                  if (isUser) ...[
                    const SizedBox(width: 12),
                    _buildAvatar(false, isUser: true),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(bool isError, {bool isUser = false}) {
    return Container(
      width: AppConstants.avatarRadius * 2,
      height: AppConstants.avatarRadius * 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isError
              ? [Colors.red, Colors.redAccent]
              : isUser
              ? [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer]
              : [Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondaryContainer],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isError ? Colors.red : Theme.of(context).colorScheme.primary).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isError
            ? Icons.error_rounded
            : isUser
            ? Icons.person_rounded
            : Icons.smart_toy_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Color _getMessageColor(bool isUser, bool isError) {
    if (isError) return Theme.of(context).colorScheme.errorContainer;
    if (isUser) return Theme.of(context).colorScheme.primary;
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  Color _getTextColor(bool isUser, bool isError) {
    if (isError) return Theme.of(context).colorScheme.onErrorContainer;
    if (isUser) return Theme.of(context).colorScheme.onPrimary;
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  BorderRadius _getMessageBorderRadius(bool isUser) {
    return BorderRadius.only(
      topLeft: const Radius.circular(AppConstants.borderRadius),
      topRight: const Radius.circular(AppConstants.borderRadius),
      bottomLeft: Radius.circular(isUser ? AppConstants.borderRadius : 8),
      bottomRight: Radius.circular(isUser ? 8 : AppConstants.borderRadius),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _buildAvatar(false),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadius),
                topRight: Radius.circular(AppConstants.borderRadius),
                bottomRight: Radius.circular(AppConstants.borderRadius),
                bottomLeft: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final value = (_typingAnimation.value + delay) % 1.0;
                    final scale = 0.5 + 0.5 * (1 - (value - 0.5).abs() * 2).clamp(0.0, 1.0);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !_isLoading,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedBuilder(
              animation: _sendButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _sendButtonAnimation.value,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _sendMessage,
                        borderRadius: BorderRadius.circular(28),
                        child: Center(
                          child: _isLoading
                              ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                              : Icon(
                            Icons.send_rounded,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}