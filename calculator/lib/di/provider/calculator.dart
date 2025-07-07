import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';
import '../../presentation/presentation.dart';

class CalculatorProvider extends StatelessWidget {
  final Widget child;

  const CalculatorProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ICalculatorLocalDataSource>(
          create: (context) => CalculatorLocalDataSource(),
        ),
      ],
      child: MultiProvider(
        providers: [
          Provider<CalculatorDataSource>(
            create: (context) => CalculatorDataSource(context.read()),
          ),
        ],
        child: MultiProvider(
          providers: [
            Provider<ICalculatorRepository>(
              create: (context) => CalculatorRepository(context.read()),
            ),
          ],
          child: MultiProvider(
            providers: [
              Provider<FetchCalculatorUseCase>(
                create: (context) => FetchCalculatorUseCase(context.read()),
              ),
              Provider<SaveCalculatorUseCase>(
                create: (context) => SaveCalculatorUseCase(context.read()),
              ),
            ],
            child: MultiProvider(
              providers: [
                ChangeNotifierProvider<CalculatorViewModel>(
                  create: (context) => CalculatorViewModel(
                    context.read(),
                    context.read(),
                    CalculatorEntity(),
                  ),
                ),
              ],
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
