import Image from "next/image"
import { Card, CardHeader, CardTitle, CardContent, CardDescription } from "@/components/ui/card"
import { Clock } from "lucide-react"
import { useGlobal } from "@/components/GlobalContext"
import { ActionReaction } from "@/lib/types"
import { PUBLIC_API_URL as API_URL } from "@/lib/config"

export default function ActionReactionCard({ item, serviceColor, serviceid, onClick }: {
  item: ActionReaction
  serviceColor: string
  serviceid: string
  onClick: () => void
}) {
  const { isTextBigger } = useGlobal()

  return (
    <Card
      className="relative border-0 group overflow-hidden cursor-pointer"
      onClick={onClick}
    >
      <div className="absolute inset-0" style={{ backgroundColor: serviceColor }} />
      <div className="absolute inset-0 bg-white opacity-0 group-hover:opacity-20 transition-opacity duration-200" />
      <div className="relative z-10">
        <CardHeader className="px-6 py-4 space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 rounded-full overflow-hidden bg-white/10 p-2 backdrop-blur-sm">
                <Image
                  src={`${API_URL}/services/${serviceid}/icon`}
                  alt={`${item.id} logo`}
                  width={40}
                  height={40}
                  className="w-full h-full object-contain"
                />
              </div>
              <CardTitle className={`${isTextBigger ? 'text-xl' : 'text-lg'} text-white font-semibold`}>
                {item.title || 'Error'}
              </CardTitle>
            </div>
            {item.frequency && (
              <div className="flex items-center px-3 py-1 rounded-full bg-white/10 backdrop-blur-sm">
                <Clock className="w-4 h-4 mr-2 text-white/80" />
                <span className={`${isTextBigger ? 'text-sm' : 'text-xs'} text-white/80`}>
                  {item.frequency}
                </span>
              </div>
            )}
          </div>
        </CardHeader>
        <CardContent className="px-6 pb-6">
          <CardDescription
            className={`${isTextBigger ? 'text-base' : 'text-sm'} text-white/80 line-clamp-3`}
          >
            {item.description}
          </CardDescription>
        </CardContent>
      </div>
    </Card>
  )
}