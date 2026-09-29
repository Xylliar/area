import { motion } from "framer-motion"
import { Button } from "@/components/ui/button"
import { Check, Loader } from "lucide-react"

interface CreateAppletButtonProps {
  isLoading: boolean
  onClick: () => void
  isButtonBigger: boolean
}

export default function CreateAppletButton({
  isLoading,
  onClick,
  isButtonBigger,
}: CreateAppletButtonProps) {
  return (
    <motion.div
      className="mt-8 text-center"
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, delay: 0.2 }}
    >
      <Button
        size="lg"
        className={`px-8 py-6 text-lg focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ${isButtonBigger ? 'py-4 text-lg' : ''}`}
        onClick={onClick}
        disabled={isLoading}
      >
        {isLoading ? (
          <Loader className="mr-2 h-5 w-5 animate-spin" />
        ) : (
          <Check className="mr-2 h-5 w-5" />
        )}
        {isLoading ? "Creating..." : "Create Applet"}
      </Button>
    </motion.div>
  )
}