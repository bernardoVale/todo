#!groovy

node('ac-release-website'){
    // Checkout sending the result variable to Tag class
    def repo = checkout scm
    
    def publishBranches = ['develop', 'master']

    // Use git commit unless we're running on master branch
    prefix = (env.BRANCH_NAME == 'master') ? 'prod' : 'dev'
    version = repo.GIT_COMMIT

    stage('Build'){
      app = docker.build("bernardovale/todo-app:${prefix}-${version}", "--build-arg APP_VERSION=${version} $WORKSPACE")
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
            docker.withRegistry("https://index.docker.io/v1/", 'registry-bvale') {
                app.push()
            }
        }
    }
}