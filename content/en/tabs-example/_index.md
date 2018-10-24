---
hidden: true
---

### Tabs with regular text:
{{< tabs name="tab" >}}
{{{< tab name="Tab 1" >}}
echo "This is tab 1."
{{< /tab >}}
{{< tab name="Tab 2" >}}
println "This is tab 2."
{{< /tab >}}}
{{< /tabs >}}

### Tabs with code blocks:
{{< tabs name="tab_with_code" >}}
{{{< tab name="Tab 1" codelang="bash" >}}
echo "This is tab 1."
{{< /tab >}}
{{< tab name="Tab 2" codelang="go" >}}
println "This is tab 2."
{{< /tab >}}}
{{< /tabs >}}

### Tabs showing installation process:
{{< tabs name="tab_installation" >}}
{{< tab name="eksctl" include="tabs/eksctl.md" />}}
{{< tab name="terraform" include="tabs/launcheks.md" />}}
{{< tab name="cloudformation" include="tabs/eks.md" />}}
{{< /tabs >}}

### Second set of tabs showing installation process:
{{< tabs name="more_tab_installation" >}}
{{< tab name="eksctl" include="tabs/eksctl.md" />}}
{{< tab name="terraform" include="tabs/launcheks.md" />}}
{{< tab name="cloudformation" include="tabs/eks.md" />}}
{{< /tabs >}}
