import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Clock } from "lucide-react"
import { useGlobal } from "@/components/GlobalContext"
import { ActionReaction } from "@/lib/types"

interface InputField {
  name: string
  regex: string
  example: string
}

export default function ActionReactionDialog({ selectedItem, onClose }: {
  selectedItem: ActionReaction | null
  onClose: () => void
}) {
  const { isTextBigger } = useGlobal()

  const renderInputs = (input_fields?: InputField[]) => {
    if (!input_fields || input_fields.length === 0) {
      return <p>No inputs required.</p>
    }
    return (
      <ul className="list-disc pl-5">
        {input_fields.map((input, index) => (
          <li key={index} className={`${isTextBigger ? 'text-base' : 'text-sm'} mb-2`}>
            <span className="font-medium">{input.name}</span>
            <p className="text-muted-foreground">Regex: {input.regex}</p>
            <p className="text-muted-foreground">Example: {input.example}</p>
          </li>
        ))}
      </ul>
    )
  }

  const renderOutputs = (output_fields?: string[]) => {
    if (!output_fields || output_fields.length === 0) {
      return <p>No outputs available.</p>
    }
    return (
      <ul className="list-disc pl-5">
        {output_fields.map((output, index) => (
          <li key={index} className={`${isTextBigger ? 'text-base' : 'text-sm'} mb-2`}>
            {output}
          </li>
        ))}
      </ul>
    )
  }

  return (
    <Dialog open={!!selectedItem} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[600px]">
        <DialogHeader>
          <DialogTitle className={isTextBigger ? 'text-2xl' : 'text-xl'}>{selectedItem?.title}</DialogTitle>
          <DialogDescription className={`mt-2 ${isTextBigger ? 'text-base' : 'text-sm'}`}>
            {selectedItem?.description}
          </DialogDescription>
        </DialogHeader>
        <div className="mt-4 space-y-4">
          {selectedItem?.frequency && (
            <div className="flex items-center">
              <Clock className="w-5 h-5 mr-2" />
              <span className={`${isTextBigger ? 'text-base' : 'text-sm'}`}>Frequency: {selectedItem.frequency}</span>
            </div>
          )}
          <div>
            <h4 className={`${isTextBigger ? 'text-lg' : 'text-base'} font-medium mb-2`}>Inputs:</h4>
            {renderInputs(selectedItem?.input_fields)}
          </div>
          {selectedItem?.output_fields && (
            <div>
              <h4 className={`${isTextBigger ? 'text-lg' : 'text-base'} font-medium mb-2`}>Outputs:</h4>
              {renderOutputs(selectedItem.output_fields)}
            </div>
          )}
          {selectedItem?.outputExample && (
            <div>
              <h4 className={`${isTextBigger ? 'text-lg' : 'text-base'} font-medium mb-2`}>Output Example:</h4>
              <pre className="bg-muted p-4 rounded-md overflow-x-auto">
                <code>{selectedItem.outputExample}</code>
              </pre>
            </div>
          )}
        </div>
        <DialogFooter className="mt-6">
          <Button onClick={onClose}>Close</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}