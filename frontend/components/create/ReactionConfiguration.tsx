import { useState } from "react"
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Button } from "@/components/ui/button"
import { AlertCircle, Plus, Trash2 } from "lucide-react"
import { useToast } from "@/hooks/use-toast"
import { ReactionInstance } from "@/lib/types"

interface ReactionConfigurationProps {
  reaction: ReactionInstance
  reactionFields: Record<string, { regex: string; example: string }>
  reactionInputs: Record<string, string>
  setReactionInputs: (inputs: Record<string, string>) => void
  actionOutputs: string[]
  onRemove: () => void
  isTextBigger: boolean
}

export default function ReactionConfiguration({
  reaction,
  reactionFields,
  reactionInputs,
  setReactionInputs,
  actionOutputs,
  onRemove,
  isTextBigger,
}: ReactionConfigurationProps) {
  const { toast } = useToast()
  const [validationErrors, setValidationErrors] = useState<Record<string, boolean>>({})
  const [dropdownOpen, setDropdownOpen] = useState<Record<string, boolean>>({})

  const validateInput = (value: string, regex: string) => {
    const replacedValue = value.replace(/\{.*?\}/g, "sample")
    const pattern = new RegExp(regex)
    return pattern.test(replacedValue)
  }

  const handleInputChange = (field: string, value: string) => {
    const regex = reactionFields[field]?.regex
    if (!regex) {
      console.error(`Regex not found for field: ${field}`)
      return
    }
    const isValid = validateInput(value, regex)

    setReactionInputs({ ...reactionInputs, [field]: value })
    setValidationErrors({ ...validationErrors, [field]: !isValid })

    if (!isValid) {
      toast({
        title: "Invalid Input",
        description: `The input for ${field} is invalid.`,
        duration: 3000,
      })
    }
  }

  const toggleDropdown = (fieldKey: string) => {
    setDropdownOpen((prev) => ({
      ...prev,
      [fieldKey]: !prev[fieldKey],
    }))
  }

  const insertIngredient = (field: string, output: string) => {
    const inputId = `reaction-${reaction.instanceId}-${field}`
    const inputElement = document.getElementById(inputId) as HTMLInputElement
    if (inputElement) {
      const cursorPosition = inputElement.selectionStart || 0
      const currentValue = inputElement.value
      const newValue = `${currentValue.slice(0, cursorPosition)}{${output}}${currentValue.slice(cursorPosition)}`
      handleInputChange(field, newValue)
      inputElement.focus()
      inputElement.selectionStart = cursorPosition + output.length + 2
      inputElement.selectionEnd = cursorPosition + output.length + 2
    }
    setDropdownOpen((prev) => ({
      ...prev,
      [field]: false,
    }))
  }

  return (
    <Card className="mb-8 shadow-none">
      <CardHeader className="flex flex-row items-center justify-between">
        <div>
          <CardTitle className={isTextBigger ? "text-lg" : "text-base"}>Reaction Configuration: {reaction.title}</CardTitle>
          <CardDescription className={isTextBigger ? "text-base" : "text-sm"}>Configure the selected reaction</CardDescription>
        </div>
        <Button variant="ghost" size="icon" onClick={onRemove}>
          <Trash2 className="h-4 w-4" />
        </Button>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {reactionFields && Object.entries(reactionFields).map(([field, { example }]) => (
            <div key={field}>
              <Label
                htmlFor={`reaction-${reaction.instanceId}-${field}`}
                className={`${isTextBigger ? "text-lg" : "text-base"} ${validationErrors[field] ? "text-red-500" : ""}`}
              >
                {field} (e.g., {example}) *
              </Label>
              <div className="flex items-center mt-1 relative">
                <Input
                  id={`reaction-${reaction.instanceId}-${field}`}
                  value={reactionInputs[field] || ""}
                  onChange={(e) => handleInputChange(field, e.target.value)}
                  className={`flex-1 ${isTextBigger ? "text-lg" : "text-base"}
                    ${validationErrors[field] ? "border-red-500" : ""}`}
                  required
                />
                {actionOutputs.length > 0 && (
                  <div className="relative ml-2">
                    <Button
                      variant="outline"
                      className="flex items-center"
                      onClick={() => toggleDropdown(field)}
                    >
                      <Plus className="w-4 h-4 mr-1" />
                    </Button>
                    {dropdownOpen[field] && (
                      <div className="absolute z-10 mt-2 w-48 bg-white border rounded-md shadow-lg">
                        {actionOutputs.map((output) => (
                          <div
                            key={output}
                            className="px-4 py-2 cursor-pointer hover:bg-gray-100"
                            onClick={() => insertIngredient(field, output)}
                          >
                            {output}
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                )}
                {validationErrors[field] && (
                  <AlertCircle className="absolute right-3 top-1/2 transform -translate-y-1/2 text-red-500 h-5 w-5" />
                )}
              </div>
            </div>
          ))}
          {!reactionFields && <div>No reaction fields available.</div>}
        </div>
      </CardContent>
    </Card>
  )
}