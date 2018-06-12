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
import javax.annotation.processing.Generated
import org.emoflon.ibex.tgg.weights.weightDefinition.HelperFunction
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.common.types.JvmType
import org.eclipse.xtext.common.types.JvmOperation

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
	
	val docForMatch = '''The comatch to calculate the weight for'''
	val docForRuleName = '''Name of the rule the match corresponds to'''
	val parameterDocForGenericMethods = 
	'''
	@param ruleName	«docForRuleName»
	@param comatch	«docForMatch»
	'''
	
	
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
		
		val abstractClass = element.toClass('''Abstract«name»''') [ defineAbstractClass(element)] 
		val concreteClass = element.toClass(name) [ defineClass(element, abstractClass)]
		acceptor.accept(abstractClass)
		acceptor.accept(concreteClass)
	}

	/**
	 * Body for the switching method
	 */
	private def String getBodyForSwitchingMethod(Iterable<TGGRule> rules) {
		'''switch(ruleName) {
		«FOR rule : rules»
			case "«rule.name»": 
				return calculateWeightFor«rule.name»(ruleName, comatch);
		«ENDFOR»
		default: 
			return this.calculateDefaultWeight(ruleName, comatch);
		}'''
	}

	/**
	 * Body for the rule method, that retrieves all nodes from the match
	 */
	private def String getBodyThatRetrievesMatchedNodes(TGGRule rule) {
		'''
		«FOR node : rule.nodes.filter[!(it instanceof TGGRuleCorr)]»
		«node.typeNameForNode» «node.name» = («node.typeNameForNode») comatch.get("«node.name»");
		«ENDFOR»
		return calculateWeightFor«rule.name»(«rule.nodes.filter[!(it instanceof TGGRuleCorr)].map[it.name].join(", ")» );'''
	}

	/**
	 * Tries to lookup the full type of the node
	 */
	private def String getTypeNameForNode(TGGRuleNode node) {
		val typename = node.type.name
		val packageName = node.type.EPackage.name
		val ref = typeRef(packageName + "." + typename)
		if (ref instanceof JvmUnknownTypeReference) {
			return "EObject"
		}
		return packageName + "." + typename
	}

	/**
	 * Creates the helper method
	 */
	private def createMethodForHelperFunction(HelperFunction helperFunction) {
		helperFunction.toMethod(helperFunction.name, helperFunction.returnType) [
			for (param : helperFunction.params) {
				parameters += param.toParameter(param.name, param.parameterType)
			}
			body = helperFunction.body
			documentation = helperFunction.documentation
			visibility = JvmVisibility.PRIVATE
			final = true
		]
	}

	/**
	 * Creates the user's default calculation method for unspecified rules
	 */
	private def createDefaultMethod(DefaultCalculation defaultCalculation) {
		defaultCalculation.toMethod("calculateDefaultWeight", typeRef(double)) [
			val p1 = defaultCalculation.toParameter("ruleName", typeRef(String))
			p1.documentation = "Name of the rule the match corresponds to"
			parameters += p1
			val p2 = defaultCalculation.toParameter("comatch", typeRef(IMatch))
			p2.documentation = "The comatch to calculate the weight for"
			parameters += p2
			body = defaultCalculation.calc
			if(defaultCalculation.documentation !== null && !defaultCalculation.documentation.empty) {
				documentation = '''«defaultCalculation.documentation»«"\n\n"»parameterDocForGenericMethods'''
			} else {
				documentation = '''Default calculation for matches of rules that do not have a specific calculation«"\n\n"»«parameterDocForGenericMethods»'''
			}
			annotations += annotationRef(Override)
			visibility = JvmVisibility.PROTECTED
		]
	}
	
	/**
	 * Creates the standard default calculation method for unspecified rules
	 */
	private def createDefaultMethodForAbstractClass(WeightDefinitionFile element) {
		element.toMethod("calculateDefaultWeight", typeRef(double)) [
			val p1 = element.toParameter("ruleName", typeRef(String))
			p1.documentation = docForRuleName
			parameters += p1
			val p2 = element.toParameter("comatch", typeRef(IMatch))
			p2.documentation = docForMatch
			parameters += p2
			body = '''return this.app.getDefaultWeightForMatch(comatch, ruleName);'''
			documentation = 
			'''Default calculation for matches of rules that do not have a specific calculationn«"\n\n"»«parameterDocForGenericMethods»'''
			visibility = JvmVisibility.PROTECTED
		]
	}

	/**
	 * Creates the rule method which retrieves the matches nodes and calls the calculation method
	 */
	private def createBasicMethodForRule(RuleWeightDefinition rule) {
		rule.toMethod('''calculateWeightFor«rule.rule.name»''', typeRef(double)) [
			documentation = 
			'''Retrieve all matched nodes and calculate the weight for «rule.rule.name»«"\n\n"»«parameterDocForGenericMethods»'''
			parameters += rule.toParameter("ruleName", typeRef(String))
			parameters += rule.toParameter("comatch", typeRef(IMatch))
			visibility = JvmVisibility.PRIVATE
			final = true
			body = '''«rule.rule.bodyThatRetrievesMatchedNodes»'''
		]
	}

	/**
	 * Adds the parameters of the rule
	 */
	private def addParametersForRule(JvmOperation method, TGGRule rule) {
		for (node : rule.nodes.filter[!(it instanceof TGGRuleCorr)]) {
				val typename = node.type.name
				val packageName = node.type.EPackage.name
				var ref = typeRef(packageName + "." + typename)
				if (ref instanceof JvmUnknownTypeReference) {
					ref = typeRef(EObject)
				}
				val p = rule.toParameter(node.name, ref)
				
				p.documentation = '''The matched element for node "«node.name»" of type "«node.type.name»"'''
				method.parameters += p
			}
	}
	
	/**
	 * Creates the documentation text for the matched parameters
	 */
	private def getDocumentationForParameters(TGGRule rule) {
		'''
		«FOR node: rule.nodes.filter[!(it instanceof TGGRuleCorr)]»
		@param «node.name»	The matched element for node "«node.name»" of type "«node.type.name»"
		«ENDFOR»
		'''
	}
	
	/**
	 * Creates the abstract weight calculation method
	 */
	private def createAbstractParameterizedMethodForRule(RuleWeightDefinition rule) {
		rule.toMethod('''calculateWeightFor«rule.rule.name»''', typeRef(double)) [
			documentation = 
				'''Weight calculation for matched nodes of rule «rule.rule.name»«"\n\n"»«rule.rule.documentationForParameters»'''
			visibility = JvmVisibility.PROTECTED
			addParametersForRule(rule.rule)
			abstract = true
		]
	}
	
	/**
	 * Creates the weight calculation method
	 */
	private def createParameterizedMethodForRule(RuleWeightDefinition rule) {
		rule.toMethod('''calculateWeightFor«rule.rule.name»''', typeRef(double)) [
			if(rule.documentation !== null && !rule.documentation.empty) {
					documentation = '''«rule.documentation»«"\n\n"»«rule.rule.documentationForParameters»'''
			} else {
				documentation = 
					'''Weight calculation for matched nodes of rule «rule.rule.name»«"\n\n"»«rule.rule.documentationForParameters»'''
			}
			
			visibility = JvmVisibility.PROTECTED
			addParametersForRule(rule.rule)
			annotations += annotationRef(Override)
			body = (rule.weightCalc as WeightCalculation).calc
		]
	}
	
	/**
	 * Creates the switching method which calls the suitable rule method
	 */
	private def createSwitchingMethod(WeightDefinitionFile element) {
		element.toMethod("calculateWeight", typeRef(double)) [
				parameters += element.toParameter("ruleName", typeRef(String))
				parameters += element.toParameter("comatch", typeRef(IMatch))
				body = '''«element.weigthDefinitions.map[it as RuleWeightDefinition].map[it.rule].bodyForSwitchingMethod»'''
				documentation = 
				'''Switching method that delegates the weight calculation to the methods dedicated to a single rule or to the default strategy if no calculation is specified.«"\n\n"»«parameterDocForGenericMethods»'''
				annotations += annotationRef(Override)
				final = true
			]
	}
	
	/**
	 * Creates the constructor for the generated class
	 */
	private def createConstructor(WeightDefinitionFile element) {
		element.toConstructor [
				documentation = 
				'''Constructor for the WeightCalculationStrategy«"\n\n"»@param app	The application strategy'''
				parameters += element.toParameter("app", typeRef(OPT))
				body = '''super(app);'''
			]
	}
	
	/**
	 * Creates the constructor for the generated class
	 */
	private def createConstructorForAbstractClass(WeightDefinitionFile element) {
		element.toConstructor [
				documentation = 
				'''Constructor for the WeightCalculationStrategy«"\n\n"»@param app	The application strategy'''
				parameters += element.toParameter("app", typeRef(OPT))
				body = '''this.app = app;'''
				visibility = JvmVisibility.PROTECTED
			]
	}
	
	
	/**
	 * Creates the reference to the strategy
	 */
	private def createFinalAppField(WeightDefinitionFile element) {
		element.toField("app", typeRef(OPT)) [
				visibility = JvmVisibility.PRIVATE
				final = true
				documentation = "The app this weight calculation strategy is registered at."
			]
	}
	
	/**
	 * Creates the contents of the class
	 */
	private def defineClass(JvmDeclaredType type, WeightDefinitionFile element, JvmType abstractSuperClass) {
		//set class properties
		type.superTypes += typeRef(abstractSuperClass)
		type.packageName = "org.emoflon.ibex.tgg.weights"
		type.visibility = JvmVisibility.PUBLIC
		type.annotations += annotationRef(Generated, "TGGWeight_Generator")
		type.documentation = 
			'''This class defines the calculation of weights of found matches.«"\n"»Calculations are defined in "«element.eResource.URI.toString»"'''

		// create constructor
		type.members += element.createConstructor

		// create the method for each weight definition
		element.weigthDefinitions.map[it as RuleWeightDefinition].forEach[
			// actual calculation method
			type.members += createParameterizedMethodForRule
		]

		// add default calculation method
		element.defaultCalc.map[it as DefaultCalculation].forEach[type.members += createDefaultMethod]
		

		// add helper methods
		element.helperFuntions.map[it as HelperFunction].forEach[
			type.members += createMethodForHelperFunction
		]
	}
	
	/**
	 * Defines the abstract base class
	 */
	private def defineAbstractClass(JvmDeclaredType type, WeightDefinitionFile element) {
		//set class properties
		type.superTypes += typeRef(IWeightCalculationStrategy)
		type.packageName = "org.emoflon.ibex.tgg.weights"
		type.visibility = JvmVisibility.DEFAULT
		type.abstract = true
		type.annotations += annotationRef(Generated, "TGGWeight_Generator")
		type.documentation = 
			'''This abstract class defines the api for the calculation of weights of found matches and provides the necessary logic to invoke them.«"\n"»Calculations are defined in "«element.eResource.URI.toString»"'''

		//create app field
		type.members += element.createFinalAppField

		// create constructor
		type.members += element.createConstructorForAbstractClass

		// add generic method for all kinds of matches
		type.members += element.createSwitchingMethod

		// create the method for each weight definition
		element.weigthDefinitions.map[it as RuleWeightDefinition].forEach[
			// method for rule that retrieves the matched nodes
			type.members += createBasicMethodForRule
			// actual calculation method
			type.members += createAbstractParameterizedMethodForRule
		]

		// add default calculation method
		type.members += element.createDefaultMethodForAbstractClass
	}
}
