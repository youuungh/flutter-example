class Message {
  final String role;
  final String content;

  const Message({
    required this.role,
    required this.content,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  Message copyWith({
    String? role,
    String? content,
  }) {
    return Message(
      role: role ?? this.role,
      content: content ?? this.content,
    );
  }

  factory Message.system(String content) => Message(role: 'system', content: content);
  factory Message.user(String content) => Message(role: 'user', content: content);
  factory Message.assistant(String content) => Message(role: 'assistant', content: content);
}

class ChatRequest {
  final String model;
  final List<Message> messages;
  final bool stream;
  final int? maxTokens;
  final double? temperature;

  const ChatRequest({
    required this.model,
    required this.messages,
    this.stream = false,
    this.maxTokens,
    this.temperature,
  });

  factory ChatRequest.fromJson(Map<String, dynamic> json) {
    return ChatRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List)
          .map((e) => Message.fromJson(e as Map<String, dynamic>))
          .toList(),
      stream: json['stream'] as bool? ?? false,
      maxTokens: json['max_tokens'] as int?,
      temperature: (json['temperature'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'model': model,
      'messages': messages.map((e) => e.toJson()).toList(),
      'stream': stream,
    };

    if (maxTokens != null) data['max_tokens'] = maxTokens;
    if (temperature != null) data['temperature'] = temperature;

    return data;
  }

  factory ChatRequest.gpt35({
    required List<Message> messages,
    bool stream = false,
    int? maxTokens = 1000,
    double? temperature = 0.7,
  }) {
    return ChatRequest(
      model: 'gpt-3.5-turbo',
      messages: messages,
      stream: stream,
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }

  factory ChatRequest.gpt4({
    required List<Message> messages,
    bool stream = false,
    int? maxTokens = 1000,
    double? temperature = 0.7,
  }) {
    return ChatRequest(
      model: 'gpt-4',
      messages: messages,
      stream: stream,
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }
}