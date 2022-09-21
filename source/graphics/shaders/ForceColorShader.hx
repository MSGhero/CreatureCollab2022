package graphics.shaders;

import h3d.shader.ScreenShader;

class ForceColorShader extends ScreenShader {
	static var SRC = {
		
		@param var texture:Sampler2D;
		@param var color:Vec4;
		@const var active:Bool;
		
		function fragment() {
			
			pixelColor = texture.get(calculatedUV);
			
			if (active) {
				pixelColor.rgb = color.rgb * pixelColor.a;
			}
		}
	};
}