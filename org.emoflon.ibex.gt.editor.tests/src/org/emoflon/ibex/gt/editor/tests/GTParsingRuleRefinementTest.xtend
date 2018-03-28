package org.emoflon.ibex.gt.editor.tests

import org.eclipse.xtext.diagnostics.Diagnostic
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.emoflon.ibex.gt.editor.gT.GTPackage
import org.emoflon.ibex.gt.editor.utils.GTFlattener
import org.emoflon.ibex.gt.editor.validation.GTValidator
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith
import org.emoflon.ibex.gt.editor.gT.Operator

/**
 * JUnit tests for rule refinement.
 */
@RunWith(XtextRunner)
@InjectWith(GTInjectorProvider)
class GTParsingRuleRefinementTest extends GTParsingTest {
	@Test
	def void validIfEmptyRuleBodyAndMultipleRefinement() {
		val file = parseHelper.parse('''
			import "«ecoreImport»"
			
			rule a {
				object1: EObject
			}
			
			rule b {
				object2: EObject
			}
			
			rule c
			refines a, b
		''')
		this.assertValid(file, 3)
	}

	@Test
	def void errorForSelfRefinement() {
		val file = parseHelper.parse('''
			import "«ecoreImport»"
			
			rule a
			refines a {
				object: EObject
			}
		''')
		this.assertFile(file)
		this.assertValidationErrors(
			file,
			GTPackage.eINSTANCE.rule,
			Diagnostic::LINKING_DIAGNOSTIC,
			"Couldn't resolve reference to Rule 'A'."
		)
	}

	@Test
	def void errorIfLoopinRulesRefinementHierarchyLevel1() {
		val file = parseHelper.parse('''
			import "«ecoreImport»"
			
			rule a
			refines b {
				object1: EObject
			}
			
			rule b
			refines a {
				object2: EObject
			}
		''')
		this.assertFile(file, 2)
		this.assertValidationErrors(
			file,
			GTPackage.eINSTANCE.rule,
			Diagnostic::LINKING_DIAGNOSTIC,
			"Couldn't resolve reference to Rule 'A'."
		)
	}

	@Test
	def void errorIfLoopinRulesRefinementHierarchyLevel2() {
		val file = parseHelper.parse('''
			import "«ecoreImport»"
			
			rule a
			refines b {
				object: EObject
			}
			
			rule b
			refines c {
				object: EObject
			}
			
			rule c
			refines a {
				object: EObject
			}
		''')
		this.assertFile(file, 3)
		this.assertValidationErrors(
			file,
			GTPackage.eINSTANCE.rule,
			Diagnostic::LINKING_DIAGNOSTIC,
			"Couldn't resolve reference to Rule 'A'."
		)
	}

	@Test
	def void errorIfNoDistinctSuperRules() {
		val file = parseHelper.parse('''
			import "«ecoreImport»"
			
			rule a {
				object: EObject
			}
			
			rule b
			refines a, a
		''')
		this.assertValidResource(file)
		this.assertValidationErrors(
			file,
			GTPackage.eINSTANCE.rule,
			GTValidator.RULE_SUPER_RULES_DUPLICATE,
			String.format(GTValidator.RULE_SUPER_RULES_DUPLICATE_MESSAGE, 'b')
		)
	}

	@Test
	def void validFlatteningOfRule() {
		val file = parseHelper.parse('''
			import "«ecoreImport»"
			
			abstract rule findClassifierWithAnnotation(name: EString) {
				classifier: EClassifier {
					.name == param::name
					-eAnnotations -> annotation
				}
			
				annotation: EAnnotation
			}
			
			rule findClassWithAnnotation
			refines findClassifierWithAnnotation(attributeName: EString) {
				classifier: EClass {
					-eAttributes -> attribute
				}
			
				attribute: EAttribute {
					.name == param::attributeName
				}
			}
		''')
		this.assertValid(file, 2)
		val flattener = new GTFlattener(file.getRule(1))
		Assert.assertFalse(flattener.hasErrors)
		Assert.assertEquals(#[], flattener.errors)

		val flattenedRule = flattener.flattenedRule
		assertParameters(flattenedRule, #{'attributeName' -> 'EString', 'name' -> 'EString'})
		Assert.assertArrayEquals(#['attributeName', 'name'], flattenedRule.parameters.map[it.name].toArray)

		Assert.assertEquals(3, flattenedRule.nodes.size);
		assertNode(flattenedRule.getNode(0), Operator.CONTEXT, "annotation", "EAnnotation", 0, 0)
		assertNode(flattenedRule.getNode(1), Operator.CONTEXT, "attribute", "EAttribute", 1, 0)
		assertNode(flattenedRule.getNode(2), Operator.CONTEXT, "classifier", "EClass", 0, 2)
	}

	@Test
	def void errorForFlatteningRuleWithInconsistentTypeDeclarations() {
		val file = parseHelper.parse('''
			import "«ecoreImport»"
			
			rule findClass(interface: EBoolean, name: EString) {
				clazz: EClass {
					.interface == param::interface
					.name == param::name
				}
			}
			
			rule findClassDuplicate
			refines findClass(interface: EBoolean, name: EBoolean) {
				clazz2: EClass {
					.interface == param::interface
				}
			}
		''')
		val flattener = new GTFlattener(file.getRule(1))
		Assert.assertTrue(flattener.hasErrors)
		val errors = #['Inconsistent type declarations for parameter name: EBoolean and EString.']
		Assert.assertEquals(errors, flattener.errors)
	}
}
