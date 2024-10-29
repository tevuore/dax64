import 'dart:collection';

import 'package:meta/meta.dart';

import '../models/statement/macro.dart';
import 'errors.dart';

@immutable
class AssemblyContext {
  final int currentMemoryAddress;

  // TeroV as label can be on empty line, do we calculate real line it is pointing?
  //       or in fact should label just be a relative address value?
  final Map<LabelName, Label> _labels;
  final Map<VariableName, MacroAssignment> _variables;
  final Map<MacroName, MacroDefinition> _macros;

  AssemblyContext._(
      this.currentMemoryAddress, this._labels, this._variables, this._macros);

  Label? label(LabelName name) => _labels[name];

  MacroAssignment? variable(VariableName name) => _variables[name];

  MacroDefinition? macro(MacroName name) => _macros[name];

  static AssemblyContext newInstance(
      {required int currentMemoryAddress,
      required Map<LabelName, Label> labels,
      required Map<VariableName, MacroAssignment> variables,
      required Map<MacroName, MacroDefinition> macros}) {
    final Map<LabelName, Label> labels_ = HashMap();
    final Map<VariableName, MacroAssignment> variables_ = HashMap();
    final Map<MacroName, MacroDefinition> macros_ = HashMap();

    labels_.addAll(labels);
    variables_.addAll(variables);
    macros_.addAll(macros);

    return AssemblyContext._(
        currentMemoryAddress, labels_, variables_, macros_);
  }

  AssemblyContext updateCopy(
      {required int currentMemoryAddress_,
      required Map<LabelName, int> resolvedLabels}) {
    final newLabels = HashMap<LabelName, Label>();
    newLabels.addAll(_labels);
    resolvedLabels.forEach((labelName, memoryAddress) {
      final labelObj = label(labelName);
      if (labelObj == null) {
        // TODO this should we catched already in parsing phase
        throw InternalAssemblerError(
            "Tried to update not existing label: $labelName");
      }
      if (labelObj.memoryAddress != null) {
        throw InternalAssemblerError(
            "Tried to set memory address for label that already has it: $labelName");
      }
      newLabels[labelName] =
          Label(name: labelName, memoryAddress: memoryAddress);
    });

    return AssemblyContext._(
        currentMemoryAddress_, newLabels, _variables, _macros);
  }
}

@immutable
class Label {
  final LabelName name;
  final int? memoryAddress;

  Label({required this.name, required this.memoryAddress});
}

typedef LabelName = String;
typedef VariableName = String;
typedef MacroName = String;
