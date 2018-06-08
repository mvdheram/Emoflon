/*
 * generated by Xtext 2.14.0
 */
package org.emoflon.ibex.tgg.weights.ui.contentassist

import java.util.Arrays
import org.eclipse.core.resources.ResourcesPlugin
import org.eclipse.core.runtime.CoreException
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor
import org.moflon.core.utilities.WorkspaceHelper
import org.eclipse.emf.ecore.util.EcoreUtil
import language.TGG
import language.TGGRule
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.resource.ContentHandler

/**
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#content-assist
 * on how to customize the content assistant.
 */
class WeightDefinitionProposalProvider extends AbstractWeightDefinitionProposalProvider {

	override completeImport_ImportURI(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		Arrays.stream(ResourcesPlugin.getWorkspace().getRoot().getProjects()) //
		.forEach [
			val modelFolder = WorkspaceHelper.getModelFolder(project);
			if (modelFolder.exists()) {
				try {
					val members = modelFolder.members();
					Arrays.stream(members).filter[it.getFileExtension().equals("xmi")].forEach [
						val uri = URI.createPlatformResourceURI(it.getFullPath().toString(), true);
						if (checkIfTGGFile(uri)) {
							acceptor.accept(createCompletionProposal('''"«uri.toString»"''', context))
						}
					];
				} catch (CoreException e) {
					// Do nothing.
				}
			}
		];
	}

	def checkIfTGGFile(URI uri) {
		val importedTGG = new ResourceSetImpl().createResource(uri, ContentHandler.UNSPECIFIED_CONTENT_TYPE);
		importedTGG.load(null);
		EcoreUtil.resolveAll(importedTGG);
		(importedTGG.contents.exists[it instanceof TGG]) 
			&& (importedTGG.contents.filter[it instanceof TGG].flatMap[(it as TGG).rules].exists[it instanceof TGGRule])
	}
}
