// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package testimpl

import (
	"os"
	"strings"
	"testing"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/cloud"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/to"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/resourcemanager/appcontainers/armappcontainers/v3"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	expectedImage   = "mcr.microsoft.com/k8se/quickstart:latest"
	expectedCPU     = 0.25
	expectedMemory  = "0.5Gi"
	mutatedTagKey   = "Mutated"
	mutatedTagValue = "true"
)

func expectedTags() map[string]*string {
	return map[string]*string{
		"Environment": to.Ptr("test"),
		"Terraform":   to.Ptr("true"),
	}
}

type appTestContext struct {
	client            *armappcontainers.ContainerAppsClient
	resourceGroupName string
	appName           string
	environmentID     string
	resourceID        string
}

func newAppTestContext(t *testing.T, ctx types.TestContext) appTestContext {
	t.Helper()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	require.NotEmpty(t, subscriptionID, "ARM_SUBSCRIPTION_ID must be set")

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	require.NoError(t, err, "create Azure credential")

	client, err := armappcontainers.NewContainerAppsClient(subscriptionID, credential, &arm.ClientOptions{
		ClientOptions: azcore.ClientOptions{Cloud: cloud.AzurePublic},
	})
	require.NoError(t, err, "create Container Apps client")

	tfOptions := ctx.TerratestTerraformOptions()
	outputContext := t.Context()

	return appTestContext{
		client:            client,
		resourceGroupName: terraform.OutputContext(t, outputContext, tfOptions, "resource_group_name"),
		appName:           terraform.OutputContext(t, outputContext, tfOptions, "name"),
		environmentID:     terraform.OutputContext(t, outputContext, tfOptions, "container_app_environment_id"),
		resourceID:        terraform.OutputContext(t, outputContext, tfOptions, "id"),
	}
}

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	assertPostApplyPlanEmpty(t, ctx)

	testCtx := newAppTestContext(t, ctx)
	assertConfiguredApp(t, testCtx)

	updateTags(t, testCtx, mutatedTags())
	defer updateTags(t, testCtx, expectedTags())

	app := getApp(t, testCtx)
	require.NotNil(t, app.Tags)
	require.NotNil(t, app.Tags[mutatedTagKey])
	assert.Equal(t, mutatedTagValue, *app.Tags[mutatedTagKey])
}

func TestComposableCompleteReadonly(t *testing.T, ctx types.TestContext) {
	assertConfiguredApp(t, newAppTestContext(t, ctx))
}

func assertConfiguredApp(t *testing.T, testCtx appTestContext) {
	t.Helper()

	app := getApp(t, testCtx)

	require.NotNil(t, app.ID)
	assertEqualFold(t, testCtx.resourceID, *app.ID)
	require.NotNil(t, app.Name)
	assert.Equal(t, testCtx.appName, *app.Name)

	require.NotNil(t, app.Identity)
	require.NotNil(t, app.Identity.Type)
	assert.Equal(t, armappcontainers.ManagedServiceIdentityTypeSystemAssigned, *app.Identity.Type)

	require.NotNil(t, app.Properties)
	require.NotNil(t, app.Properties.EnvironmentID)
	assertEqualFold(t, testCtx.environmentID, *app.Properties.EnvironmentID)
	require.NotNil(t, app.Properties.Configuration)
	require.NotNil(t, app.Properties.Configuration.ActiveRevisionsMode)
	assert.Equal(t, armappcontainers.ActiveRevisionsModeSingle, *app.Properties.Configuration.ActiveRevisionsMode)
	require.NotNil(t, app.Properties.Configuration.Ingress)
	require.NotNil(t, app.Properties.Configuration.Ingress.External)
	assert.Equal(t, false, *app.Properties.Configuration.Ingress.External)

	require.NotNil(t, app.Properties.Template)
	require.Len(t, app.Properties.Template.Containers, 1)
	container := app.Properties.Template.Containers[0]
	require.NotNil(t, container.Image)
	assert.Equal(t, expectedImage, *container.Image)
	require.NotNil(t, container.Resources)
	require.NotNil(t, container.Resources.CPU)
	assert.Equal(t, expectedCPU, *container.Resources.CPU)
	require.NotNil(t, container.Resources.Memory)
	assert.Equal(t, expectedMemory, *container.Resources.Memory)

	require.NotNil(t, app.Tags)
	require.NotNil(t, app.Tags["Environment"])
	assert.Equal(t, "test", *app.Tags["Environment"])
	require.NotNil(t, app.Tags["Terraform"])
	assert.Equal(t, "true", *app.Tags["Terraform"])
}

func assertEqualFold(t *testing.T, expected, actual string) {
	t.Helper()
	assert.Equal(t, strings.ToLower(expected), strings.ToLower(actual))
}

func assertPostApplyPlanEmpty(t *testing.T, ctx types.TestContext) {
	t.Helper()

	out, err := terraform.PlanContextE(t, t.Context(), ctx.TerratestTerraformOptions())
	require.NoError(t, err, "post-apply terraform plan")
	t.Logf("post-apply terraform plan:\n%s", out)
	if !strings.Contains(out, "No changes") {
		t.Fatalf("terraform configuration not idempotent\n%s", out)
	}
}

func getApp(t *testing.T, testCtx appTestContext) armappcontainers.ContainerApp {
	t.Helper()

	app, err := testCtx.client.Get(t.Context(), testCtx.resourceGroupName, testCtx.appName, nil)
	require.NoError(t, err, "get Container App")
	return app.ContainerApp
}

func mutatedTags() map[string]*string {
	tags := expectedTags()
	tags[mutatedTagKey] = to.Ptr(mutatedTagValue)
	return tags
}

func updateTags(t *testing.T, testCtx appTestContext, tags map[string]*string) {
	t.Helper()

	poller, err := testCtx.client.BeginUpdate(t.Context(), testCtx.resourceGroupName, testCtx.appName, armappcontainers.ContainerApp{
		Tags: tags,
	}, nil)
	require.NoError(t, err, "begin update Container App tags")

	_, err = poller.PollUntilDone(t.Context(), nil)
	require.NoError(t, err, "complete update Container App tags")
}
