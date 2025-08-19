import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/multiplier_generator.dart';

Builder multiplyBuilder(BuilderOptions options) =>
    SharedPartBuilder([MultiplierGenerator()], "multiply");
