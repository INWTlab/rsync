// Template Jenkinsfile for R CI/CD Tasks
// Author: Sebastian Warnholz
pipeline {
    agent none
    options { disableConcurrentBuilds() }
    environment {
        CUR_PROJ = 'rsync' // github repo name
        CUR_PKG = 'rsync' // r-package name
        CUR_PKG_FOLDER = '.' // defaults to root
    }
    stages {

        stage('Testing with R-3.5.1') {
            agent { label 'test' }
            // when { not { branch 'depl' } }
            steps {
                withCredentials([
                    file(credentialsId: 'rsync-aws-testing-config', variable: 'CONFIG'),
                    file(credentialsId: 'rsync-aws-testing-credentials', variable: 'CREDENTIALS')]
                ) {
                    sh '''
                    mkdir .aws
                    cp -f $CREDENTIALS .aws/credentials
                    cp -f $CONFIG .aws/config
                    docker build --pull -t tmp-$CUR_PROJ .
                    docker run --rm --network host tmp-$CUR_PROJ check
                    docker rmi tmp-$CUR_PROJ
                    '''
                }
                cleanWs()
            }
        }

        stage('Deploy R-package') {
            agent { label 'eh2' }
            when { branch 'depl' }
            steps {
                sh '''
                rm -vf *.tar.gz
                docker pull inwt/r-batch:3.5.1
                docker run --rm --network host -v $PWD:/app --user `id -u`:`id -g` inwt/r-batch:3.5.1 R CMD build $CUR_PKG_FOLDER
                R -e "drat::insertPackage('`echo $CUR_PKG`_`grep -E '^Version:[ \t]*[0-9.]{3,10}' $CUR_PKG_FOLDER/DESCRIPTION | awk '{print $2}'`.tar.gz', '/var/www/html/r-repo'); drat::archivePackages(repopath = '/var/www/html/r-repo')"
                '''
            }
        }

    }

}
