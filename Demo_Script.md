# Demo Script

1. Start The [Container Development Kit](https://developers.redhat.com/products/cdk/download/)
1. Create a new project called `zap-demo`
   1. Via cli: `oc new-project zap-demo`
1. Deploy the image to OpenShift: `oc new-build -l 'role=jenkins-slave' https://github.com/rht-labs/owasp-zap-openshift.git`
1. Switch to the OpenShift web console and show the build executing
   1. Can capture the image URL here or in the step below
1. Once the build is complete, navigate to "Builds->Images" and copy the registry URL for the new container
   1. Should look like: 172.30.1.1:5000/zap-demo/owasp-zap-openshift
1. Deploy Persistent Jenkins installation - Point out that you may want to use additional storage space.
   1. Via cli: `oc process openshift//jenkins-persistent -p VOLUME_CAPACITY=5Gi | oc create -f -`
   1. Show Jenkins being spun up in web console
1. Log in to the Jenkins instance
1. Click on "Manage Jenkins"
1. Click on "Manage Plugins"
1. Select the "Available" tab
1. Filter for "HTML Publisher"
1. Tick the "HTML Publisher" plugin and click "Download now and install after restart"
1. Tick the box "Restart Jenkins when installation is complete and no jobs are running"
1. While Jenkins restarts, explain that the HTML Publisher plugin allows us to add reports to the build history and explain that we will show this in more detail later
1. Log back in to Jenkins
1. Click on "Manage Jenkins -> Configure System"
1. Scroll down to the Kubernetes Cloud configuration
   1. Highlight that we are using OpenShift and that the `zap-demo` namespace has already been populated.
1. Click on "Add Pod Template" and select "Kubernetes Pod Template"
1. Fill in the "Name" and "Labels" as `zap-demo`
1. Click on "Add" under "Containers"
```
Name: jnlp
Docker image: 172.30.1.1:5000/zap-demo/owasp-zap-openshift  << The Docker image registry may be different on different OpenShift installations
Working directory: /tmp                                     << Explain that this MOUNTS a working directory, it does not set the working directory
Command to run slave agent: <blank>
Arguments to pass to the command: ${computer.jnlpmac} ${computer.name}
Allocate pseudo-TTY: Unchecked
```
1. Max number of instances: 1
1. Time in minutes to retain slave when idle: 10
1. Click "Save"
1. Click "New Item" on the Jenkins main page
1. Set the name to "Example", select "Pipeline" as the project type, then click "OK"
1. Tick the box "Do not allow concurrent builds"
1. Insert the pipeline script:
```groovy
stage('Get a ZAP Pod') {
    node('zap-demo') {
        stage('Scan Web Application') {
            dir('/zap') {
                def retVal = sh returnStatus: true, script: '/zap/zap-baseline.py -r baseline.html -t http://<some-web-site>'
                publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: true, reportDir: '/zap/wrk', reportFiles: 'baseline.html', reportName: 'ZAP Baseline Scan', reportTitles: 'ZAP Baseline Scan'])
                echo "Return value is: ${retVal}"
            }
        }
    }
}
```
1. Set the web address to be scanned and explain the Pipeline script
1. Switch back to Jenkins and run the Example build, wait for the ZAP baseline scan to complete. 
   1. While waiting, explain that we could also push in additional and more detailed specifications for the test by either copying in ZAP configurations or mounting Kubernetes ConfigMap file literals as provided by the security teams. These could be configured on a case-by-case basis part of the initial planning with the security team.
1. Once the scan is complete, show the saved ZAP report in the build sidebar.

* Discuss methods to customize how the ZAP scans are run. 
  * Mounted ConfigMap files?
  * Mounted volumes
  * Download config via HTTP/CURL
  * https://github.com/zaproxy/zaproxy/wiki/Docker

* More detailed options for baseline scan:
  * https://github.com/zaproxy/zaproxy/wiki/ZAP-Baseline-Scan