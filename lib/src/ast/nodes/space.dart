import 'package:flutter/widgets.dart';

import '../options.dart';
import '../size.dart';
import '../syntax_tree.dart';

class SpaceNode extends LeafNode {
  final Measurement dimension;
  SpaceNode({
    @required this.dimension,
  });
  
  @override
  Widget buildWidget(Options options, List<Widget> childWidgets, List<Options> childOptions) {
    // TODO: implement buildWidget
    throw UnimplementedError();
  }

  @override
  // TODO: implement leftType
  AtomType get leftType => throw UnimplementedError();

  @override
  // TODO: implement rightType
  AtomType get rightType => throw UnimplementedError();

  @override
  bool shouldRebuildWidget(Options oldOptions, Options newOptions) {
    // TODO: implement shouldRebuildWidget
    throw UnimplementedError();
  }

  @override
  // TODO: implement width
  int get width => throw UnimplementedError();

}