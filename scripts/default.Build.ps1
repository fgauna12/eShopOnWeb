$ErrorActionPreference = 'Stop'

task Clean {
    if (Test-Path -Path $BuildRoot/build/){
        Remove-Item -Path $BuildRoot/build/ -Recurse -Force -Confirm:$false
    }
}

task Build {
    Set-Location ../src/Web/
    exec {
        dotnet publish -o $BuildRoot/build/
    }
    Compress-Archive -Path $BuildRoot/build/* -DestinationPath $BuildRoot/build/out.zip
}

task TerraformInit {
    Set-Location ../iac/staging
    exec {
        terraform init -input=false
    }
}

task TerraformPlan {
    Set-Location ../iac/staging
    exec {
        terraform plan -out tf.plan -input=false -no-color
    }
}

task TerraformApply {
    Set-Location ../iac/staging
    exec {
        terraform apply -no-color -input=false tf.plan 
        $script:AzureAppServiceName = $(terraform output app_service_name)
        $script:AzureAppServiceHostname = $(terraform output app_service_hostname)
        $script:ResourceGroupName = $(terraform output resource_group_name)
    }
}

task WebAppPublish {
    Set-Location ../src/Web/
    write-build "Waiting 60 seconds before deploying" -Color Yellow
    Start-Sleep -Seconds 60
    write-build "Deploying..." -Color Gray
    exec {
        az webapp deployment source config-zip -g $ResourceGroupName -n $AzureAppServiceName --src $BuildRoot/build/out.zip
    }
}

task TerraformDestroy {
    Set-Location ../iac/staging
    exec {
        terraform destroy -auto-approve
    }
}

task . Clean, Build, TerraformInit, TerraformPlan, TerraformApply, WebAppPublish