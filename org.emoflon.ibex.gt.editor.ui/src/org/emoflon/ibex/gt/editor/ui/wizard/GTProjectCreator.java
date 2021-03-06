package org.emoflon.ibex.gt.editor.ui.wizard;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.inject.Inject;
import com.google.inject.Provider;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IFileSystemAccess2;
import org.eclipse.xtext.generator.OutputConfiguration;
import org.eclipse.xtext.ui.util.PluginProjectFactory;
import org.eclipse.xtext.ui.wizard.AbstractPluginProjectCreator;
import org.eclipse.xtext.ui.wizard.DefaultProjectInfo;
import org.emoflon.ibex.gt.editor.ui.builder.GTNature;

/**
 * Creator for Graph Transformation Projects.
 */
public class GTProjectCreator extends AbstractPluginProjectCreator {
	@Inject
	private GTNewFileInitialContents initialContents;

	@Inject
	private Provider<EclipseResourceFileSystemAccess2> fileSystemAccessProvider;

	@Override
	protected PluginProjectFactory createProjectFactory() {
		PluginProjectFactory projectFactory = super.createProjectFactory();
		projectFactory.setWithPluginXml(false);
		return projectFactory;
	}

	@Override
	protected DefaultProjectInfo getProjectInfo() {
		return (DefaultProjectInfo) super.getProjectInfo();
	}

	@Override
	protected String getModelFolderName() {
		return "src";
	}

	@Override
	protected List<String> getAllFolders() {
		return ImmutableList.of(getModelFolderName(), "src-gen");
	}

	@Override
	protected String[] getProjectNatures() {
		ArrayList<String> natures = Lists.newArrayList(GTNature.NATURE_ID);
		natures.addAll(Lists.newArrayList(super.getProjectNatures()));
		return natures.toArray(new String[natures.size()]);
	}

	@Override
	protected String[] getBuilders() {
		ArrayList<String> builders = Lists.newArrayList(GTNature.getRequiredBuilders());
		builders.addAll(Lists.newArrayList(super.getBuilders()));
		return builders.toArray(new String[builders.size()]);
	}

	@Override
	protected List<String> getRequiredBundles() {
		return Lists.newArrayList();
	}

	@Override
	protected void enhanceProject(final IProject project, final IProgressMonitor monitor) throws CoreException {
		IFileSystemAccess2 access = getFileSystemAccess(project, monitor);
		initialContents.generateInitialContents(access, project);
		project.refreshLocal(IResource.DEPTH_INFINITE, monitor);
	}

	protected IFileSystemAccess2 getFileSystemAccess(final IProject project, final IProgressMonitor monitor) {
		EclipseResourceFileSystemAccess2 access = fileSystemAccessProvider.get();
		access.setContext(project);
		access.setMonitor(monitor);
		OutputConfiguration defaultOutput = new OutputConfiguration(IFileSystemAccess.DEFAULT_OUTPUT);
		defaultOutput.setDescription("Output Folder");
		defaultOutput.setOutputDirectory("./");
		defaultOutput.setOverrideExistingResources(true);
		defaultOutput.setCreateOutputDirectory(true);
		defaultOutput.setCleanUpDerivedResources(false);
		defaultOutput.setSetDerivedProperty(false);
		defaultOutput.setKeepLocalHistory(false);
		HashMap<String, OutputConfiguration> outputConfigurations = new HashMap<String, OutputConfiguration>();
		outputConfigurations.put(IFileSystemAccess.DEFAULT_OUTPUT, defaultOutput);
		access.setOutputConfigurations(outputConfigurations);
		return access;
	}
}
