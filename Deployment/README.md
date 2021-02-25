**Steps:**

1.  make migsetup
    
    - Sets up a single node kubernetes cluster with the help of kubespray.

2.  Update mme and ignite image names in the values.yaml file of the corresponding helm charts.

3.  make migutbox

    - Installs mme and ignite helm charts in the 'omec' namespace
    
4.  Execute the test cases from 'runtestcase' container of ignite. 

5.  make reset-migutbox 

    - Uninstalls the helm chart

6.  'make clean': 

    -  Removes the kubernetes cluster.
