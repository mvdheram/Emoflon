/*
 * generated by Xtext 2.14.0
 */
package org.emoflon.ibex.tgg.weights.ui.labeling

import com.google.inject.Inject
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.emoflon.ibex.tgg.weights.weightDefinition.WeightDefinitionFile
import org.eclipse.xtext.xbase.ui.labeling.XbaseLabelProvider
import org.emoflon.ibex.tgg.weights.weightDefinition.RuleWeightDefinition
import org.emoflon.ibex.tgg.weights.weightDefinition.DefaultCalculation
import org.emoflon.ibex.tgg.weights.weightDefinition.HelperFunction
import org.emoflon.ibex.tgg.weights.weightDefinition.Import
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.resource.ContentHandler
import org.eclipse.emf.ecore.util.EcoreUtil
import language.TGG

/**
 * Provides labels for EObjects.
 * 
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#label-provider
 */
class WeightDefinitionLabelProvider extends XbaseLabelProvider {
	
	/**
	 * Cached imported resource
	 */
	var Resource importedTGG

	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}
	
	def text(WeightDefinitionFile file) {
		val fileName = file.eResource.URI.lastSegment
		fileName.substring(0, fileName.length - 5)
	}
	
	def text(RuleWeightDefinition ruleElement) {
		ruleElement.rule.name
	}
	
	def text(DefaultCalculation defaultCalc) {
		"Default Weight Calculation"
	}
	
	def text(Import importNode) {
		val importUri = importNode.importURI
		val uri = URI.createURI(importUri);
		val resolvedUri = uri.resolve(URI.createPlatformResourceURI("/", true))
		if ((importedTGG === null) || (importedTGG.URI != resolvedUri)) {
			importedTGG = new ResourceSetImpl().createResource(resolvedUri, ContentHandler.UNSPECIFIED_CONTENT_TYPE);
			importedTGG.load(null);
			EcoreUtil.resolveAll(importedTGG);
		}
		try {
			val tgg = importedTGG.contents
				.filter[it instanceof TGG].get(0) as TGG
			return '''TGG «tgg.name» ([«tgg.src.map[name].join(",")»]<=>[«tgg.trg.map[name].join(",")»])'''
		} catch (Exception e) {
			return '''TGG (unresolvable, at «importNode.importURI»)'''
		}
	}
	
	def text(HelperFunction helperFunc) {
		var text = '''«helperFunc.name»('''
		var first = true
		for(param : helperFunc.params) {
			if(!first)
				text += ", "
			first = false
			text += param.parameterType.type.simpleName
		}
		text += ''') : «helperFunc.returnType.type.simpleName»'''
	}
}
