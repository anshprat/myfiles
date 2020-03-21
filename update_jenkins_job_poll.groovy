import hudson.triggers.*
import hudson.maven.MavenModuleSet
import org.jenkinsci.plugins.workflow.job.*
pollSpec = 'H/5 * * * *'


TriggerDescriptor SCM_TRIGGER_DESCRIPTOR = Hudson.instance.getDescriptorOrDie(SCMTrigger.class)


  def logSpec = { it, getTrigger -> String spec = getTrigger(it)?.getSpec();
    if (spec) println (it.getFullName() + " with spec " + spec);
  if ( spec && spec.trim() == "* * * * *") {
    println("This job to be updated");
    trigger = new SCMTrigger(pollSpec);
    it.addTrigger(trigger)

    }

}

println("--- SCM Polling for Pipeline jobs ---")
Jenkins.getInstance().getAllItems(WorkflowJob.class).each() { logSpec(it, {it.getSCMTrigger()}) ;  }



println("\n--- SCM Polling for FreeStyle jobs ---")
Jenkins.getInstance().getAllItems(FreeStyleProject.class).each() { logSpec(it, {it.getSCMTrigger()}) }
