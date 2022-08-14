pipeline {
    agent any
    options {
        buildDiscarder(logRotator(daysToKeepStr: '10', numToKeepStr: '10'))
        timeout(time: 12, unit: 'HOURS')
        timestamps()
    }
    triggers {
          cron '@midnight'
    }
    environment {
        SLACK_AUTH_TOKEN  = credentials('SLACK_AUTH_TOKEN')
        SLACK_CHANNEL_ID  = credentials('SLACK_CHANNEL_ID')
    }
    stages {
        stage('Checkout') {
            steps {
                git(
                        url: 'https://github.com/managedkaos/100-days-of-code-bot.git',
                        branch: "${env.BRANCH_NAME}"
                   )
            }
        }
        stage('Requirements') {
            steps {
                sh('''
                        python3 -m venv local
                        source ./local/bin/activate
                        pip install --upgrade pip
                        pip install --requirement requirements.txt
                        ''')
            }
        }
        stage('Build') {
            steps {
                sh('''
                        source ./local/bin/activate
                        python ./sprint.py
                        ''')
            }
        }
    }
}
