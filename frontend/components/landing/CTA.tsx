import { Button } from "@/components/ui/button"
import Link from "next/link"

export default function CTASection() {
  return (
    <section className="py-16 px-8">
      <div className="max-w-4xl mx-auto text-center">
        <h2 className="text-3xl font-bold mb-4">Ready to Automate?</h2>
        <p className="text-muted-foreground mb-8">
          Start connecting your services and create your first automation today.
        </p>
        <Button asChild size="lg">
          <Link href="/register">Create Account</Link>
        </Button>
      </div>
    </section>
  )
}