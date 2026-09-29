class InputField {
  String name;
  String regex;
  String example;

  InputField({
    required this.name,
    required this.regex,
    required this.example,
  });

  factory InputField.fromJson(Map<String, dynamic> json) {
    return InputField(
      name: json['name'],
      regex: json['regex'],
      example: json['example'],
    );
  }

  InputField.defaultInputField()
      : name = '',
        regex = '',
        example = '';
  void setInputField(String name, String regex, String example) {
    this.name = name;
    this.regex = regex;
    this.example = example;
  }
}