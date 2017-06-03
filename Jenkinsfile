#!groovy
node {
    stage('Checkout'){
          checkout scm
    }
    stage('Build'){
      gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
      app = docker.build("bernardovale/todo-app:${gitCommit}", "-f ci/staging/Dockerfile ${WORKSPACE}")
    }
    stage('Unit Tests'){
      app.inside{
        sh 'pytest tests/unit --junit-xml results/unit.xml'
        junit '**/results/unit.xml'
      }
    }
    stage('Deploy Staging'){
      sh "GIT_COMMIT=${gitCommit} docker-compose -p todo -f staging.yml up -d"
    }
    stage('Functional Tests'){
        docker.image('mongo').withRun(){ m ->
          app.inside("-e MONGODB_HOST=mongo -e APP_ENV=staging --link ${m.id}:mongo"){
            sh 'pytest tests/functional --junit-xml results/functional.xml'
            junit '**/results/functional.xml'
          }
        }
    }
    stage('Publish'){
      docker.withRegistry("https://index.docker.io/v1/", 'registry') {
        app.push()
      }
    }
}