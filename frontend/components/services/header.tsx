'use client'

import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { useRouter } from "next/navigation"
import Image from "next/image"
import { ArrowLeft } from "lucide-react"
import { useGlobal } from "@/components/GlobalContext"
import { Service } from "@/lib/types"
import { PUBLIC_API_URL as API_URL } from "@/lib/config"

export default function ServiceHeader({ service }: { service: Service }) {
  const router = useRouter()
  const { isTextBigger, isButtonBigger } = useGlobal()

  return (
    <div className="mx-4 sm:mx-8 md:mx-16 lg:mx-32">
      <Card
        style={{ backgroundColor: service.color }}
        className="border-0 rounded-xl shadow-lg py-24 px-8 sm:px-12 min-h-[300px] flex items-center shadow-none"
      >
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
          <div className="flex flex-col md:flex-row items-center justify-between">
            <div className="flex items-center mb-4 md:mb-0">
              <div className="w-24 h-24 rounded-full overflow-hidden flex items-center justify-center p-2 bg-white/10">
                <Image
                  src={`${API_URL}/services/${service.id}/icon`}
                  alt={`${service.name} logo`}
                  width={96}
                  height={96}
                  className="object-contain"
                  priority
                />
              </div>
              <h1 className={`ml-4 font-bold text-white ${isTextBigger ? 'text-5xl' : 'text-4xl'}`}>
                {service.name}
              </h1>
            </div>
            <Button
              onClick={() => router.back()}
              variant="ghost"
              className={`${isButtonBigger ? 'text-lg py-3 px-5' : 'text-base py-2 px-4'}
                bg-white text-black hover:bg-gray-100 transition-colors duration-200`}
            >
              <ArrowLeft className="w-5 h-5 mr-2" />
              Back to Services
            </Button>
          </div>
        </div>
      </Card>
    </div>
  )
}