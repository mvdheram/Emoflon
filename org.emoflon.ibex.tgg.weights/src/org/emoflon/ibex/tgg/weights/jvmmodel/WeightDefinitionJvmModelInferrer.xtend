/*
 * generated by Xtext 2.14.0
 */
package org.emoflon.ibex.tgg.weights.jvmmodel

import com.google.inject.Inject
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import org.emoflon.ibex.tgg.weights.weightDefinition.WeightDefinitionFile
import org.emoflon.ibex.tgg.weights.weightDefinition.RuleWeightDefinition
import language.TGGRule
import language.TGGRuleCorr
import org.emoflon.ibex.tgg.weights.weightDefinition.WeightCalculation
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.common.types.JvmUnknownTypeReference
import language.TGGRuleNode
import org.eclipse.xtext.common.types.JvmVisibility
import org.emoflon.ibex.tgg.operational.matches.IMatch
import org.emoflon.ibex.tgg.operational.strategies.OPT
import org.emoflon.ibex.tgg.weights.weightDefinition.DefaultCalculation
import org.emoflon.ibex.tgg.operational.strategies.IWeightCalculationStrategy
import org.eclipse.xtext.xbase.jvmmodel.JvmAnnotationReferenceBuilder
import javax.annotation.processing.Generated

/**
 * <p>Infers a JVM model from the source model.</p> 
 * 
 * <p>The JVM model should contain all elements that would appear in the Java code 
 * which is generated from the source model. Other models link against the JVM model rather than the source model.</p>     
 */
class WeightDefinitionJvmModelInferrer extends AbstractModelInferrer {

	/**
	 * convenience API to build and initialize JVM types and their members.
	 */
	@Inject extension JvmTypesBuilder
	@Inject extension JvmAnnotationReferenceBuilder

	/**
	 * The dispatch method {@code infer} is called for each instance of the
	 * given element's type that is contained in a resource.
	 * 
	 * @param element
	 *            the model to create one or more
	 *            {@link org.eclipse.xtext.common.types.JvmDeclaredType declared
	 *            types} from.
	 * @param acceptor
	 *            each created
	 *            {@link org.eclipse.xtext.common.types.JvmDeclaredType type}
	 *            without a container should be passed to the acceptor in order
	 *            get attached to the current resource. The acceptor's
	 *            {@link IJvmDeclaredTypeAcceptor#accept(org.eclipse.xtext.common.types.JvmDeclaredType)
	 *            accept(..)} method takes the constructed empty type for the
	 *            pre-indexing phase. This one is further initialized in the
	 *            indexing phase using the lambda you pass as the last argument.
	 * @param isPreIndexingPhase
	 *            whether the method is called in a pre-indexing phase, i.e.
	 *            when the global index is not yet fully updated. You must not
	 *            rely on linking using the index if isPreIndexingPhase is
	 *            <code>true</code>.
	 */
	def dispatch void infer(WeightDefinitionFile element, IJvmDeclaredTypeAcceptor acceptor,
		boolean isPreIndexingPhase) {
		val fileName = element.eResource.URI.lastSegment
		val name = fileName.substring(0, fileName.length - 5)
		acceptor.accept(element.toClass(name)) [
			superTypes += typeRef(IWeightCalculationStrategy)
			packageName = "org.emoflon.ibex.tgg.weights"
			visibility = JvmVisibility.PUBLIC
			annotations += annotationRef(Generated)
			documentation = '''This class defines the calculation of weights of found matches.''' + "\n" +
				'''Calculations are defined in "«element.eResource.URI.toString»"'''

			members += element.toField("app", typeRef(OPT)) [
				visibility = JvmVisibility.PRIVATE
				final = true
				documentation = "The app this weight calculation strategy is registered at."
			]

			// create constructor
			members += element.toConstructor [
				documentation = "Constructor for the WeightCalculationStrategy"
				parameters += element.toParameter("app", typeRef(OPT))
				body = '''this.app = app;'''
			]

			// add generic method for all kinds of matches
			members += element.toMethod("calculateWeight", typeRef(double)) [
				parameters += element.toParameter("ruleName", typeRef(String))
				parameters += element.toParameter("comatch", typeRef(IMatch))
				body = '''«getBodyForGenericMethod(element.weigthDefinitions.map[it as RuleWeightDefinition].map[it.rule].toList())»'''
				documentation = '''Switching method that delegates the weight calculation to the methods dedicated to a single rule or to the default strategy if no calculation is specified'''
				annotations += annotationRef(Override)
				final = true
			]

			// create the method for each weight definition
			for (rule : element.weigthDefinitions) {
				val r = rule as RuleWeightDefinition
				// method for rule that retrieves the matched nodes
				members += r.toMethod('''calculateWeightFor«r.rule.name»''', typeRef(double)) [
					documentation = '''Retrieve all matched nodes and calculate the weight for «r.rule.name»'''
					parameters += element.toParameter("ruleName", typeRef(String))
					parameters += element.toParameter("comatch", typeRef(IMatch))
					visibility = JvmVisibility.PRIVATE
					final = true
					body = '''«r.rule.bodyThatRetrievesMatchedNodes»'''
				]

				// actual calculation method
				members += r.toMethod('''calculateWeightFor«r.rule.name»''', typeRef(double)) [
					documentation = '''Weight calculation for matched nodes of rule «r.rule.name»'''
					visibility = JvmVisibility.PROTECTED
					for (node : r.rule.nodes.filter[!(it instanceof TGGRuleCorr)]) {
						val typename = node.type.name
						val packageName = node.type.EPackage.name
						var ref = typeRef(packageName + "." + typename)
						if (ref instanceof JvmUnknownTypeReference) {
							ref = typeRef(EObject)
						}
						val p = r.toParameter(node.name, ref)
						p.documentation = '''The matched element for node "«node.name»" of type "«node.type.name»"'''
						parameters += p
					}
					body = (r.weightCalc as WeightCalculation).calc
				]
			}

			// add default calculation method
			val defaultCalculation = element.^default as DefaultCalculation
			if (defaultCalculation !== null) {
				members += defaultCalculation.toMethod("calculateDefaultWeight", typeRef(double)) [
					val p1 = element.toParameter("ruleName", typeRef(String))
					p1.documentation = "Name of the rule the match corresponds to"
					parameters += p1
					val p2 = element.toParameter("comatch", typeRef(IMatch))
					p2.documentation = "The comatch to calculate the weight for"
					parameters += p2
					body = defaultCalculation.calc
					documentation = '''Default calculation for matches of rules that do not have a specific calculation'''
					visibility = JvmVisibility.PROTECTED
				]
			} else {
				members += element.toMethod("calculateDefaultWeight", typeRef(double)) [
					val p1 = element.toParameter("ruleName", typeRef(String))
					p1.documentation = "Name of the rule the match corresponds to"
					parameters += p1
					val p2 = element.toParameter("comatch", typeRef(IMatch))
					p2.documentation = "The comatch to calculate the weight for"
					parameters += p2
					body = '''return this.app.getDefaultWeightForMatch(comatch, ruleName);'''
					documentation = '''Default calculation for matches of rules that do not have a specific calculation'''
					visibility = JvmVisibility.PROTECTED
				]
			}
		]
	}

	def String getBodyForGenericMethod(Iterable<TGGRule> rules) {
		'''switch(ruleName) {
		«FOR rule : rules»
			case "«rule.name»": 
				return calculateWeightFor«rule.name»(ruleName, comatch);
		«ENDFOR»
		default: 
			return this.calculateDefaultWeight(ruleName, comatch);
		}'''
	}

	def String getBodyThatRetrievesMatchedNodes(TGGRule rule) {
		'''«FOR node : rule.nodes.filter[!(it instanceof TGGRuleCorr)]»
			«node.typeNameForNode» «node.name» = («node.typeNameForNode») comatch.get("«node.name»");
		«ENDFOR»''' +
			'''return calculateWeightFor«rule.name»(«rule.nodes.filter[!(it instanceof TGGRuleCorr)].map[it.name].join(", ")» );'''
	}

	def String getTypeNameForNode(TGGRuleNode node) {
		val typename = node.type.name
		val packageName = node.type.EPackage.name
		val ref = typeRef(packageName + "." + typename)
		if (ref instanceof JvmUnknownTypeReference) {
			return "EObject"
		}
		return packageName + "." + typename
	}
}
