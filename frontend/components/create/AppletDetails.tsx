import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import TagInput from "@/components/ui/input-tag"
import { Badge } from "@/components/ui/badge"
import { Switch } from "@/components/ui/switch"

interface AppletDetailsProps {
  appletTitle: string
  setAppletTitle: (title: string) => void
  appletDescription: string
  setAppletDescription: (description: string) => void
  customTags: string[]
  setCustomTags: React.Dispatch<React.SetStateAction<string[]>>
  isTextBigger: boolean
  isPublic?: boolean
  setIsPublic?: (isPublic: boolean) => void
  isAdminUser?: boolean
}

export default function AppletDetails({
  appletTitle,
  setAppletTitle,
  appletDescription,
  setAppletDescription,
  customTags,
  setCustomTags,
  isTextBigger,
  isPublic,
  setIsPublic,
  isAdminUser
}: AppletDetailsProps) {
  return (
    <Card className="mb-8 shadow-none">
      <CardHeader>
        <CardTitle className={isTextBigger ? "text-lg" : "text-base"}>Applet Details</CardTitle>
        <CardDescription className={isTextBigger ? "text-base" : "text-sm"}>Enter a title and description for your applet</CardDescription>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          <div>
            <Label htmlFor="applet-title" className={isTextBigger ? "text-lg" : "text-base"}>Title</Label>
            <Input
              id="applet-title"
              value={appletTitle}
              onChange={(e) => setAppletTitle(e.target.value)}
              placeholder="Enter applet title"
              className={`mt-1 ${isTextBigger ? "text-lg" : "text-base"}`}
              required
            />
          </div>
          <div>
            <Label htmlFor="applet-description" className={isTextBigger ? "text-lg" : "text-base"}>Description</Label>
            <Textarea
              id="applet-description"
              value={appletDescription}
              onChange={(e) => setAppletDescription(e.target.value)}
              placeholder="Enter applet description"
              className={`mt-1 ${isTextBigger ? "text-lg" : "text-base"}`}
              required
            />
          </div>
          <div>
            <Label className={isTextBigger ? "text-lg" : "text-base"}>Applet Tags</Label>
            <TagInput
              tags={customTags}
              setTags={setCustomTags}
            />
          </div>
          {customTags.length > 0 && (
            <div>
              <Label className={isTextBigger ? 'text-base' : 'text-sm'}>Tags</Label>
              <div className="flex flex-wrap gap-2 mt-2">
                {customTags.map((tag, index) => (
                  <Badge key={index} variant="secondary">
                    {tag}
                  </Badge>
                ))}
              </div>
            </div>
          )}
          {isAdminUser && (
            <div className="flex items-center space-x-2">
              <Switch
                id="public-mode"
                checked={isPublic}
                onCheckedChange={setIsPublic}
              />
              <Label
                htmlFor="public-mode"
                className={`font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70 ${
                  isTextBigger ? 'text-base' : 'text-sm'
                }`}
              >
                Create as public applet
              </Label>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )
}