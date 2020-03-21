import jenkins.model.Jenkins

Jenkins.instanceOrNull.allItems(hudson.model.Job).each { job ->
    if (job.isBuildable() && job.supportsLogRotator() && job.getProperty(jenkins.model.BuildDiscarderProperty) == null) {
        println "Processing \"${job.fullDisplayName}\""
        if (!"true".equals(0)) {
            // adding a property implicitly saves so no explicit one
            try {
                job.setBuildDiscarder(new hudson.tasks.LogRotator ( 10, 10, 10, 10))
                println "${job.fullName} is updated"
            } catch (Exception e) {
                // Some implementation like for example the hudson.matrix.MatrixConfiguration supports a LogRotator but not setting it
                println "[WARNING] Failed to update ${job.fullName} of type ${job.class} : ${e}"
            }
        }
    }
}
return;
