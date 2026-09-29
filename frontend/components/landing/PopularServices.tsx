import { Card, CardContent } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import Link from "next/link"
import Image from "next/image"
import { PUBLIC_API_URL as API_URL } from "@/lib/config"

interface Service {
  id: string;
  name: string;
  color?: string;
}

export default function PopularServicesSection({ services }: { services: Service[] }) {
  return (
    <section className="py-16 px-8 bg-muted/50">
      <div className="max-w-6xl mx-auto">
        <h2 className="text-3xl font-bold mb-12 text-center">Popular Services</h2>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-8">
          {services.map((service) => (
            <ServiceCard key={service.id} service={service} />
          ))}
        </div>
        <div className="text-center mt-8">
          <Button variant="outline" asChild>
            <Link href="/explore">View All Services</Link>
          </Button>
        </div>
      </div>
    </section>
  )
}

function ServiceCard({ service }: { service: Service }) {
  return (
    <Card
      className="text-center transition-all duration-300 hover:scale-105 hover:shadow-lg cursor-pointer"
      style={{
        backgroundColor: service.color || 'transparent',
        color: service.color ? 'white' : 'inherit'
      }}
    >
      <CardContent className="pt-6">
        <div className="mb-4 flex justify-center relative w-12 h-12 mx-auto">
          <Image
            src={`${API_URL}/services/${service.id}/icon`}
            alt={service.name}
            fill
            className="object-contain rounded-lg"
            sizes="48px"
            priority
            unoptimized
          />
        </div>
        <p className="font-medium text-sm">{service.name}</p>
      </CardContent>
    </Card>
  )
}