/*
 * generated by Xtext 2.14.0
 */
package org.emoflon.ibex.tgg.weights.parser.antlr;

import java.io.InputStream;
import org.eclipse.xtext.parser.antlr.IAntlrTokenFileProvider;

public class WeightDefinitionAntlrTokenFileProvider implements IAntlrTokenFileProvider {

	@Override
	public InputStream getAntlrTokenFile() {
		ClassLoader classLoader = getClass().getClassLoader();
		return classLoader.getResourceAsStream("org/emoflon/ibex/tgg/weights/parser/antlr/internal/InternalWeightDefinition.tokens");
	}
}
