package ui;

import h2d.Object;
import h2d.Scene;

@:forward
abstract ScrollLayer(Object) from Object to Object { }

abstract Scale(Float) from Float to Float { }

abstract ScrollChild(Bool) from Bool to Bool { }