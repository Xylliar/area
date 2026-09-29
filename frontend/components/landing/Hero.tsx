import { Button } from "@/components/ui/button"
import Link from "next/link"

export default function HeroSection() {
  return (
    <section className="flex flex-col items-center justify-center min-h-[60vh] bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 p-8">
      <h1 className="text-4xl sm:text-6xl font-bold mb-4 text-center">AREA</h1>
      <p className="text-xl sm:text-2xl text-muted-foreground text-center max-w-2xl mb-8">
        Connect Your Digital World: Automate Actions Between Your Favorite Services
      </p>
      <Button asChild size="lg">
        <Link href="/explore">Get Started</Link>
      </Button>
    </section>
  )
}