elifePipeline {
    def commit
    stage 'Checkout', {
        checkout scm
        commit = elifeGitRevision()
    }

    node('containers-jenkins-plugin') {
        stage 'Build images', {
            checkout scm
            sh "IMAGE_TAG=${commit} docker-compose build"
        }
        stage 'Run tests', {
            sh "IMAGE_TAG=${commit} ./project_tests.sh"
        }

        stage 'Smoke tests', {
            try {
                sh "IMAGE_TAG=${commit} docker-compose up &"
                sh 'docker-wait-healthy contentmine_contentmine_1 60'
            } finally {
                sh 'docker-compose down -v'
            }
        }

        elifeMainlineOnly {
            stage 'Push images', {
                sh './push.sh'
            }
        }
    }
}