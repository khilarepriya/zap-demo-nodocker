pipeline {
  agent any

  environment {
    PYTHONPATH = "${WORKSPACE}"
    ZAP_REPORT = "zap_report.html"
    ZAP_REPORT_PDF = "zap_report.pdf"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git branch: 'main', credentialsId: 'github-token', url: 'https://github.com/khilarepriya/zap-demo-nodocker.git'
      }
    }

    stage('Install Dependencies') {
      steps {
        sh '''
          python3 -m venv venv
          . venv/bin/activate
          pip install --upgrade pip
          pip install -r requirements.txt
        '''
      }
    }

    stage('Start Web App') {
      steps {
        sh '''
          echo "🐍 Activating virtualenv..."
          . venv/bin/activate

          echo "🚀 Starting Flask app in background..."
          nohup venv/bin/python app.py > app.log 2>&1 &
          APP_PID=$!
          echo "Flask started with PID: $APP_PID"

          echo "⏳ Waiting for app to start..."
          for i in {1..10}; do
            if curl -s http://127.0.0.1:5010 > /dev/null; then
              echo "✅ Flask app is running!"
              exit 0
            else
              echo "⏳ Still waiting for Flask... ($i)"
              sleep 2
            fi
          done

          echo "❌ App did not start in time."
          echo "📜 Logs:"
          cat app.log
          echo "🛑 Killing Flask process $APP_PID"
          kill $APP_PID || true
          exit 1
        '''
      }
    }

    stage('Run ZAP Scan') {
      steps {
        sh '''
          echo "⚙️ Starting ZAP scan on http://localhost:5010"

          /opt/zaproxy/zap.sh -cmd \
            -port 8091 \
            -quickurl http://localhost:5010 \
            -quickout zap_report.html \
            -quickprogress

          echo "✅ ZAP scan completed"
          ls -lh zap_report.html || echo "⚠️ Report not found"
        #  cat zap_report.html || echo "⚠️ Report is empty"
        '''
      }
    }

    // ✅ New Stage: Convert ZAP HTML report to PDF
    stage('Convert ZAP Report to PDF') {
      steps {
        sh '''
          if [ -f "${ZAP_REPORT}" ]; then
            echo "📄 Converting ${ZAP_REPORT} to PDF..."
            wkhtmltopdf "${ZAP_REPORT}" "${ZAP_REPORT_PDF}" || {
              echo "❌ Failed to convert HTML to PDF"
              exit 1
            }
            echo "✅ PDF generated: ${ZAP_REPORT_PDF}"
          else
            echo "❌ ${ZAP_REPORT} not found"
            exit 1
          fi
        '''
      }
    }

    stage('Publish ZAP Report') {
      steps {
        publishHTML([
          allowMissing: false,
          alwaysLinkToLastBuild: true,
          keepAll: true,
          reportDir: '.',
          reportFiles: 'zap_report.html',
          reportName: 'ZAP DAST Scan Report'
        ])
      }
    }

    stage('Show ZAP Report URL') {
      steps {
        echo "📄 ZAP Report available at: ${env.BUILD_URL}zap-dast-scan-report"
      }
    }
  }

  post {
    always {
      sh 'pkill -f app.py || true'
      sh 'ls -lh zap_report.html || echo "ZAP report not found!"'
      archiveArtifacts artifacts: 'zap_report.html', fingerprint: true
      script {
        def reportUrl = "${env.BUILD_URL}artifact/zap_report.html"
        echo "📄 ZAP Report available at: ${reportUrl}"
      }
    }
  }
}
