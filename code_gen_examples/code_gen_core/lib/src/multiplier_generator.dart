import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:code_gen_core/annotations.dart';
import 'package:source_gen/source_gen.dart';

class MultiplierGenerator extends GeneratorForAnnotation<Multiplier> {
  @override
  generateForAnnotatedElement(
    Element2 element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final numValue = annotation.read('value').literalValue as num;

    return 'num ${element.name3}Multiplied() => ${element.name3} * $numValue;';
  }
}
