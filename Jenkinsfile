pipeline {
  agent {
    kubernetes {
      // Without cloud, Jenkins will pick the first cloud in the list
      cloud "kubernetes"
      label "jenkins-agent"
      yamlFile "jenkins-build-pod.yaml"
    }
  }

  environment {
    DOCKERHUB_CREDENTIALS=credentials('kdknive')
  }

   stages {
    stage('Snyk Test') {
        steps {
            snykSecurity(
                snykInstallation: 'snyk@latest',
                snykTokenId: 'kdknive-snyk',
            )
        }
    }
    stage('Build & Push') {
        steps {
            container(name: 'kaniko', shell: '/busybox/sh') {
              withEnv(['PATH+EXTRA=/busybox']) {
                sh '''#!/busybox/sh -xe
                  /kaniko/executor \
                    --dockerfile Dockerfile \
                    -v `pwd`/ \
                    --verbosity debug \
                    --insecure \
                    --skip-tls-verify \
                    --destination kdknive/snyk-goof-jenkins:latest
                '''
                }
            }
        }
    }
    // stage("Build") {
    //   steps {
    //     dir("hello-app") {
    //       container("gcloud") {
    //         // Cheat by using Cloud Build to help us build our container
    //         sh "gcloud builds submit -t ${params.IMAGE_URL}:${GIT_COMMIT}"
    //       }
    //     }
    //   }
    // }

    stage("Deploy") {
      steps {
        container("kubectl") {
          sh """cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: snyk-goof-jenkins
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: snyk-goof-jenkins
  template:
    metadata:
      labels:
        app: snyk-goof-jenkins
    spec:
      containers:
      - name: snyk-goof-jenkins
        image: kdknive/snyk-goof-jenkins:latest
        ports:
            - name: one
              containerPort: 3001
            - name: two
              containerPort: 9229
---
apiVersion: v1
kind: Service
metadata:
  name: snyk-goof-jenkins-lb
  namespace: jenkins
spec:
  type: LoadBalancer
  selector:
    app: snyk-goof-jenkins
  ports:
    - protocol: TCP
      port: 3001
      targetPort: 3001
"""
          sh "kubectl rollout status deployments/snyk-goof-jenkins"
        }
      }
    }
  }
}