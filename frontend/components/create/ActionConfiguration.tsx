import { useState } from "react"
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { AlertCircle } from "lucide-react"
import { useToast } from "@/hooks/use-toast"

interface ActionConfigurationProps {
  actionFields: Record<string, { regex: string; example: string }>
  actionInputs: Record<string, string>
  setActionInputs: (inputs: Record<string, string>) => void
  isTextBigger: boolean
}

export default function ActionConfiguration({
  actionFields,
  actionInputs,
  setActionInputs,
  isTextBigger,
}: ActionConfigurationProps) {
  const { toast } = useToast()
  const [validationErrors, setValidationErrors] = useState<Record<string, boolean>>({})

  const validateInput = (value: string, regex: string) => {
    const replacedValue = value.replace(/\{.*?\}/g, "sample")
    const pattern = new RegExp(regex)
    return pattern.test(replacedValue)
  }

  const handleInputChange = (field: string, value: string) => {
    const regex = actionFields[field]?.regex
    if (!regex) {
      console.error(`Regex not found for field: ${field}`)
      return
    }
    const isValid = validateInput(value, regex)

    setActionInputs({ ...actionInputs, [field]: value })
    setValidationErrors({ ...validationErrors, [field]: !isValid })

    if (!isValid) {
      toast({
        title: "Invalid Input",
        description: `The input for ${field} is invalid.`,
        duration: 3000,
      })
    }
  }

  return (
    <Card className="mb-8 shadow-none">
      <CardHeader>
        <CardTitle className={isTextBigger ? "text-lg" : "text-base"}>Action Configuration</CardTitle>
        <CardDescription className={isTextBigger ? "text-base" : "text-sm"}>Configure the selected action</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {Object.entries(actionFields).map(([field, { example }]) => (
            <div key={field}>
              <Label
                htmlFor={`action-${field}`}
                className={`${isTextBigger ? "text-lg" : "text-base"} ${validationErrors[field] ? "text-red-500" : ""}`}
              >
                {field} (e.g., {example}) *
              </Label>
              <div className="flex items-center mt-1 relative">
                <Input
                  id={`action-${field}`}
                  value={actionInputs[field] || ""}
                  onChange={(e) => handleInputChange(field, e.target.value)}
                  className={`flex-1 ${isTextBigger ? "text-lg" : "text-base"}
                    ${validationErrors[field] ? "border-red-500" : ""}`}
                  required
                />
                {validationErrors[field] && (
                  <AlertCircle className="absolute right-3 top-1/2 transform -translate-y-1/2 text-red-500 h-5 w-5" />
                )}
              </div>
            </div>
          ))}
        </div>
      </CardContent>
    </Card>
  )
}