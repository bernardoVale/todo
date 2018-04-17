#!groovy

node('docker'){
    registry = 'nexus.avenuecode.com'

    stage('Checkout'){
        repo = checkout scm
    }
    publishBranches = ['develop', 'master']
    version = repo.GIT_COMMIT

    stage('Build'){
      app = docker.build("$registry/todo/app:$version", "--build-arg APP_VERSION=${version} $WORKSPACE")
    }
    stage('Unit Tests'){
        docker.image('mongo').withRun(){ m ->
          app.inside("-e MONGODB_HOST=mongo -e APP_ENV=staging --link ${m.id}:mongo"){
            sh 'pytest tests/functional --junit-xml results/functional.xml'
            junit '**/results/functional.xml'
          }
        }
    }
    if(env.BRANCH_NAME in publishBranches){
        stage('Publish'){
            withDockerRegistry([credentialsId: 'nexus-docker', url: 'https://nexus.avenuecode.com']) {
                app.push()
            }
        }
    }
}
