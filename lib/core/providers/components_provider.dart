import 'package:flutter/material.dart';
import 'package:ai_pc_builder_project/core/data/components_hardcode.dart';
import 'package:ai_pc_builder_project/core/classes/component.dart';

class ComponentsProvider with ChangeNotifier {
  List<List<Component>> armado = [];

  void createArmado() {
    armado = componentList; // aca se trae la informacion de el components hardcode, aca hay que pedir a la api y despues con eso a firebase.
    print("creando armado de componentes..."); // se ejecuta cuando se toca el boton armar pc
    notifyListeners();
  }
}
